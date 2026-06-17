import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../models/cv_builder_models.dart';

class CvVisualPdfRenderer {
  static const double _a4Width = 595.28;
  static const double _a4Height = 841.89;
  static const double _letterWidth = 612;
  static const double _letterHeight = 792;

  final Map<String, Uint8List> _imageCache = <String, Uint8List>{};

  Future<List<int>> build({
    required CvDocumentModel document,
    required CvTemplateModel template,
  }) async {
    final Map<String, dynamic> layout = _layoutFromTemplate(template);
    final Map<String, dynamic> pageJson = _asMap(layout['page']);
    final String pageSize = pageJson['size']?.toString() ?? template.pageSize;
    final double sourceWidth = _asDouble(pageJson['width'], 794);
    final double sourceHeight = _asDouble(pageJson['height'], 1123);
    final Size pdfPageSize = _pdfPageSize(pageSize);
    final double scaleX = pdfPageSize.width / sourceWidth;
    final double scaleY = pdfPageSize.height / sourceHeight;
    final double fontScale = math.min(scaleX, scaleY);
    final PdfDocument pdfDocument = PdfDocument();
    pdfDocument.pageSettings.size = pdfPageSize;
    pdfDocument.pageSettings.margins.all = 0;

    final List<PdfPage> pages = <PdfPage>[];
    PdfPage pageAt(int index) {
      while (pages.length <= index) {
        pages.add(pdfDocument.pages.add());
      }
      return pages[index];
    }

    final String backgroundColor =
        pageJson['backgroundColor']?.toString() ?? '#FFFFFF';
    final List<Map<String, dynamic>> elements = _asListOfMaps(layout['elements']);
    final Set<int> paintedBackgroundPages = <int>{};
    void paintBackground(int pageIndex) {
      if (!paintedBackgroundPages.add(pageIndex)) return;
      _drawPageBackground(
        page: pageAt(pageIndex),
        pageSize: pdfPageSize,
        backgroundColor: backgroundColor,
      );
    }

    if (elements.isEmpty) {
      paintBackground(0);
    } else {
      final List<_PositionedLayoutElement> positionedElements =
          _layoutTopLevelElements(
        elements: elements,
        document: document,
        template: template,
      ).where((_PositionedLayoutElement item) => item.visible && item.height > 0).toList()
        ..sort(
          (_PositionedLayoutElement first, _PositionedLayoutElement second) {
            final int zIndexCompare = _asDouble(first.element['zIndex'], 0)
                .compareTo(_asDouble(second.element['zIndex'], 0));
            if (zIndexCompare != 0) return zIndexCompare;
            return first.sourceY.compareTo(second.sourceY);
          },
        );

      for (final _PositionedLayoutElement positionedElement in positionedElements) {
        final int pageIndex = (positionedElement.sourceY / sourceHeight)
            .floor()
            .clamp(0, 9999)
            .toInt();
        final Rect sourceRect = Rect.fromLTWH(
          positionedElement.sourceX,
          positionedElement.sourceY,
          positionedElement.width,
          positionedElement.height,
        );
        final Rect rect = Rect.fromLTWH(
          sourceRect.left * scaleX,
          (sourceRect.top - pageIndex * sourceHeight) * scaleY,
          sourceRect.width * scaleX,
          sourceRect.height * scaleY,
        );

        paintBackground(pageIndex);
        await _drawLayoutElement(
          page: pageAt(pageIndex),
          element: positionedElement.element,
          rect: rect,
          sourceRect: sourceRect,
          pageScaleX: scaleX,
          pageScaleY: scaleY,
          document: document,
          template: template,
          parentSectionKey: null,
          fontScale: fontScale,
        );
      }
    }

    if (pages.isEmpty) pageAt(0);
    final List<int> bytes = await pdfDocument.save();
    pdfDocument.dispose();
    return bytes;
  }

  Future<void> _drawLayoutElement({
    required PdfPage page,
    required Map<String, dynamic> element,
    required Rect rect,
    required Rect sourceRect,
    required double pageScaleX,
    required double pageScaleY,
    required CvDocumentModel document,
    required CvTemplateModel template,
    required String? parentSectionKey,
    required double fontScale,
    Map<String, dynamic>? dynamicItemData,
  }) async {
    final String type = element['type']?.toString() ?? 'text';
    final Map<String, dynamic> style = _themedStyle(
      _asMap(element['style']),
      document: document,
      template: template,
    );

    if (type == 'section') {
      await _drawSectionElement(
        page: page,
        element: element,
        rect: rect,
        sourceRect: sourceRect,
        pageScaleX: pageScaleX,
        pageScaleY: pageScaleY,
        document: document,
        template: template,
        fontScale: fontScale,
      );
      return;
    }

    if (_isLine(type)) {
      _drawLine(page: page, type: type, rect: rect, style: style, fontScale: fontScale);
      return;
    }

    final String value = _elementValue(
      element: element,
      document: document,
      template: template,
      parentSectionKey: parentSectionKey,
      dynamicItemData: dynamicItemData,
    );
    final bool isPhoto = _isPhotoElement(type, element, template);

    if (type == 'rectangle' || type == 'circle' || isPhoto) {
      await _drawShapeOrPhoto(
        page: page,
        type: type,
        rect: rect,
        style: style,
        photoUrl: isPhoto ? value : null,
        fontScale: fontScale,
      );
      return;
    }

    if (type == 'icon') {
      _drawIcon(page: page, element: element, rect: rect, style: style, fontScale: fontScale);
      return;
    }

    if (_shouldDrawAsList(
      type: type,
      element: element,
      template: template,
      parentSectionKey: parentSectionKey,
    )) {
      _drawList(
        page: page,
        element: element,
        rect: rect,
        style: style,
        value: value,
        fontScale: fontScale,
      );
      return;
    }

    if (value.trim().isEmpty) return;
    _drawText(
      page: page,
      element: element,
      rect: rect,
      style: style,
      value: value,
      fontScale: fontScale,
    );
  }

  Future<void> _drawSectionElement({
    required PdfPage page,
    required Map<String, dynamic> element,
    required Rect rect,
    required Rect sourceRect,
    required double pageScaleX,
    required double pageScaleY,
    required CvDocumentModel document,
    required CvTemplateModel template,
    required double fontScale,
  }) async {
    final String sectionKey =
        _asMap(element['contentBinding'])['sectionKey']?.toString() ?? '';
    final CvTemplateSectionModel? section = _sectionByKey(template, sectionKey);
    final Map<String, dynamic> designerJson = _asMap(
      element['sectionDesignerJson'] ?? section?.designerJson,
    );
    final Map<String, dynamic> canvas = _asMap(designerJson['canvas']);
    final List<Map<String, dynamic>> children = _asListOfMaps(designerJson['elements']);

    if (children.isEmpty) {
      _drawPlainSection(
        page: page,
        rect: rect,
        section: section,
        document: document,
        fontScale: fontScale,
      );
      return;
    }

    final double canvasWidth = _asDouble(canvas['width'], sourceRect.width);
    final double canvasHeight = _asDouble(canvas['height'], sourceRect.height);
    final CvTemplateFieldModel? dynamicField = _dynamicItemsFieldForSection(section);
    final List<Map<String, dynamic>> dynamicItems = _dynamicItemValuesForSection(
      document: document,
      section: section,
      dynamicField: dynamicField,
    );

    if (dynamicField != null && dynamicItems.isNotEmpty) {
      double nextTop = rect.top;
      double sourceNextTop = sourceRect.top;
      final double repeatGap = math.max(0, dynamicField.repeatGap);
      for (final Map<String, dynamic> itemData in dynamicItems) {
        final List<_PositionedLayoutElement> itemChildren = _layoutSectionChildren(
          children: children,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
          sectionWidth: sourceRect.width,
          sectionHeight: sourceRect.height,
          document: document,
          template: template,
          parentSectionKey: sectionKey,
          dynamicItemData: itemData,
        );
        final double itemSourceHeight = _positionedBottom(itemChildren);
        await _drawSectionChildren(
          page: page,
          rect: Rect.fromLTWH(rect.left, nextTop, rect.width, itemSourceHeight * pageScaleY),
          sourceRect: Rect.fromLTWH(sourceRect.left, sourceNextTop, sourceRect.width, itemSourceHeight),
          children: itemChildren,
          document: document,
          template: template,
          parentSectionKey: sectionKey,
          fontScale: fontScale,
          pageScaleX: pageScaleX,
          pageScaleY: pageScaleY,
          dynamicItemData: itemData,
        );
        nextTop += (itemSourceHeight + repeatGap) * pageScaleY;
        sourceNextTop += itemSourceHeight + repeatGap;
      }
      return;
    }

    final List<_PositionedLayoutElement> positionedChildren = _layoutSectionChildren(
      children: children,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      sectionWidth: sourceRect.width,
      sectionHeight: sourceRect.height,
      document: document,
      template: template,
      parentSectionKey: sectionKey,
    );

    await _drawSectionChildren(
      page: page,
      rect: rect,
      sourceRect: sourceRect,
      children: positionedChildren,
      document: document,
      template: template,
      parentSectionKey: sectionKey,
      fontScale: fontScale,
      pageScaleX: pageScaleX,
      pageScaleY: pageScaleY,
    );
  }

  Future<void> _drawSectionChildren({
    required PdfPage page,
    required Rect rect,
    required Rect sourceRect,
    required List<_PositionedLayoutElement> children,
    required CvDocumentModel document,
    required CvTemplateModel template,
    required String parentSectionKey,
    required double fontScale,
    required double pageScaleX,
    required double pageScaleY,
    Map<String, dynamic>? dynamicItemData,
  }) async {
    final List<_PositionedLayoutElement> visibleChildren = children
        .where((_PositionedLayoutElement child) => child.visible && child.height > 0)
        .toList()
      ..sort(
        (_PositionedLayoutElement first, _PositionedLayoutElement second) {
          final int zIndexCompare = _asDouble(first.element['zIndex'], 0)
              .compareTo(_asDouble(second.element['zIndex'], 0));
          if (zIndexCompare != 0) return zIndexCompare;
          return first.sourceY.compareTo(second.sourceY);
        },
      );

    for (final _PositionedLayoutElement child in visibleChildren) {
      final Rect childSourceRect = Rect.fromLTWH(
        sourceRect.left + child.sourceX,
        sourceRect.top + child.sourceY,
        child.width,
        child.height,
      );
      final Rect childRect = Rect.fromLTWH(
        rect.left + child.sourceX * pageScaleX,
        rect.top + child.sourceY * pageScaleY,
        child.width * pageScaleX,
        child.height * pageScaleY,
      );
      await _drawLayoutElement(
        page: page,
        element: child.element,
        rect: childRect,
        sourceRect: childSourceRect,
        pageScaleX: pageScaleX,
        pageScaleY: pageScaleY,
        document: document,
        template: template,
        parentSectionKey: parentSectionKey,
        fontScale: fontScale,
        dynamicItemData: dynamicItemData,
      );
    }
  }

  void _drawPlainSection({
    required PdfPage page,
    required Rect rect,
    required CvTemplateSectionModel? section,
    required CvDocumentModel document,
    required double fontScale,
  }) {
    if (section == null) return;
    double nextY = rect.top;
    final PdfFont titleFont = _fontFor(weight: 800, size: 13 * fontScale);
    final PdfFont valueFont = _fontFor(weight: 400, size: 10 * fontScale);
    final PdfBrush titleBrush = _brush(document.themeColor) ?? PdfSolidBrush(PdfColor(0, 107, 63));
    final PdfBrush valueBrush = PdfBrushes.black;
    page.graphics.drawString(
      section.title,
      titleFont,
      brush: titleBrush,
      bounds: Rect.fromLTWH(rect.left, nextY, rect.width, 22 * fontScale),
    );
    nextY += 28 * fontScale;

    for (final CvTemplateFieldModel field in section.fields) {
      final dynamic rawValue = _sectionData(document.formData, section.key)[field.key];
      final String value = _displayValue(rawValue, field.type);
      if (value.isEmpty) continue;
      page.graphics.drawString(
        value,
        valueFont,
        brush: valueBrush,
        bounds: Rect.fromLTWH(rect.left, nextY, rect.width, 60 * fontScale),
        format: PdfStringFormat(lineSpacing: 2 * fontScale),
      );
      nextY += 66 * fontScale;
    }
  }

  Future<void> _drawShapeOrPhoto({
    required PdfPage page,
    required String type,
    required Rect rect,
    required Map<String, dynamic> style,
    required String? photoUrl,
    required double fontScale,
  }) async {
    final PdfBrush? fillBrush = _brush(style['backgroundColor']?.toString());
    final PdfPen? borderPen = _borderPen(style, fontScale: fontScale);

    if (fillBrush != null) {
      if (type == 'circle') {
        page.graphics.drawEllipse(rect, brush: fillBrush);
      } else {
        page.graphics.drawRectangle(brush: fillBrush, bounds: rect);
      }
    }

    if (photoUrl != null && photoUrl.trim().startsWith('http')) {
      final Uint8List? imageBytes = await _loadImageBytes(photoUrl.trim());
      if (imageBytes != null) {
        try {
          page.graphics.drawImage(PdfBitmap(imageBytes), rect);
        } catch (_) {}
      }
    }

    if (borderPen != null) {
      if (type == 'circle') {
        page.graphics.drawEllipse(rect, pen: borderPen);
      } else {
        page.graphics.drawRectangle(pen: borderPen, bounds: rect);
      }
    }
  }

  void _drawLine({
    required PdfPage page,
    required String type,
    required Rect rect,
    required Map<String, dynamic> style,
    required double fontScale,
  }) {
    final PdfPen pen = _borderPen(style, fontScale: fontScale) ??
        PdfPen(PdfColor(17, 24, 39), width: fontScale.clamp(0.5, 9999).toDouble());
    if (type == 'verticalLine') {
      final double x = rect.left + rect.width / 2;
      page.graphics.drawLine(pen, Offset(x, rect.top), Offset(x, rect.bottom));
      return;
    }
    final double y = rect.top + rect.height / 2;
    page.graphics.drawLine(pen, Offset(rect.left, y), Offset(rect.right, y));
  }

  void _drawText({
    required PdfPage page,
    required Map<String, dynamic> element,
    required Rect rect,
    required Map<String, dynamic> style,
    required String value,
    required double fontScale,
  }) {
    final String text = _cleanText(value);
    if (text.isEmpty) return;

    page.graphics.drawString(
      text,
      _fontFor(
        weight: _asDouble(style['fontWeight'], 400).round(),
        size: _asDouble(style['fontSize'], 12) * fontScale,
      ),
      brush: _brush(style['color']?.toString()) ?? PdfBrushes.black,
      bounds: rect,
      format: PdfStringFormat(
        alignment: _textAlignment(style['textAlign']?.toString()),
        lineSpacing: _lineSpacing(style, fontScale),
      ),
    );
  }

  void _drawList({
    required PdfPage page,
    required Map<String, dynamic> element,
    required Rect rect,
    required Map<String, dynamic> style,
    required String value,
    required double fontScale,
  }) {
    final List<String> items = _listItemsFromValue(value);
    if (items.isEmpty) return;

    final bool numbered = _isNumberedList(element: element, value: value);
    final double fontSize = _asDouble(style['fontSize'], 12) * fontScale;
    final double lineHeight = _asDouble(style['lineHeight'], 1.25);
    final PdfFont font = _fontFor(
      weight: _asDouble(style['fontWeight'], 400).round(),
      size: fontSize,
    );
    final PdfBrush brush = _brush(style['color']?.toString()) ?? PdfBrushes.black;
    final PdfStringFormat format = PdfStringFormat(
      alignment: _textAlignment(style['textAlign']?.toString()),
      lineSpacing: _lineSpacing(style, fontScale),
    );

    double nextY = rect.top;
    for (int index = 0; index < items.length; index += 1) {
      final String item = items[index].trim();
      if (item.isEmpty) continue;

      final String marker = numbered ? '${index + 1}. ' : '• ';
      final String lineText = '$marker$item';
      final double itemHeight = _estimatedTextBlockHeight(
        text: lineText,
        availableWidth: rect.width,
        fontSize: fontSize,
        lineHeight: lineHeight,
      );
      if (nextY >= rect.bottom) break;

      page.graphics.drawString(
        lineText,
        font,
        brush: brush,
        bounds: Rect.fromLTWH(rect.left, nextY, rect.width, itemHeight),
        format: format,
      );
      nextY += itemHeight;
    }
  }

  bool _shouldDrawAsList({
    required String type,
    required Map<String, dynamic> element,
    required CvTemplateModel template,
    required String? parentSectionKey,
  }) {
    if (_isListFieldType(type)) return true;

    final Map<String, dynamic> binding = _asMap(element['contentBinding']);
    final String? fieldKey = _nonEmptyString(binding['fieldKey']) ??
        _nonEmptyString(element['fieldKey']);
    final String? elementLabel = _nonEmptyString(element['label']);
    if (fieldKey == null && elementLabel == null) return false;

    for (final CvTemplateSectionModel section in template.schema.sections) {
      if (parentSectionKey != null && !_sameKey(section.key, parentSectionKey)) {
        continue;
      }
      for (final CvTemplateFieldModel field in section.fields) {
        if ((_sameOptionalKey(field.key, fieldKey) ||
                _sameOptionalKey(field.label, fieldKey) ||
                _sameOptionalKey(field.key, elementLabel) ||
                _sameOptionalKey(field.label, elementLabel)) &&
            _isListFieldType(field.type)) {
          return true;
        }

        for (final CvTemplateDynamicItemFieldModel itemField in field.itemFields) {
          if ((_sameOptionalKey(itemField.key, fieldKey) ||
                  _sameOptionalKey(itemField.label, fieldKey) ||
                  _sameOptionalKey(itemField.key, elementLabel) ||
                  _sameOptionalKey(itemField.label, elementLabel)) &&
              _isListFieldType(itemField.type)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  bool _sameOptionalKey(String first, String? second) =>
      second != null && _sameKey(first, second);

  bool _isListFieldType(String value) {
    final String type = value.trim().toLowerCase();
    return type == 'list' ||
        type == 'lists' ||
        type == 'bulletlist' ||
        type == 'bullet_list' ||
        type == 'numberlist' ||
        type == 'number_list' ||
        type == 'orderedlist' ||
        type == 'ordered_list';
  }

  bool _isNumberedList({
    required Map<String, dynamic> element,
    required String value,
  }) {
    final String style = element['listStyle']?.toString().trim().toLowerCase() ?? '';
    if (style == 'number' || style == 'numbered' || style == 'ordered') {
      return true;
    }
    return RegExp(r'^\s*\d+[.)]\s+', multiLine: true).hasMatch(value);
  }

  List<String> _listItemsFromValue(String value) {
    return _cleanText(value)
        .split('\n')
        .map(
          (String item) => item
              .replaceFirst(RegExp(r'^\s*(?:[•\-*]\s+|\d+[.)]\s+)'), '')
              .trim(),
        )
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  double _estimatedTextBlockHeight({
    required String text,
    required double availableWidth,
    required double fontSize,
    required double lineHeight,
  }) {
    final double safeWidth = math.max(8, availableWidth).toDouble();
    final int charsPerLine = math.max(8, (safeWidth / math.max(4, fontSize * 0.52)).floor());
    int lineCount = 0;
    for (final String rawLine in text.split('\n')) {
      final int length = rawLine.trim().isEmpty ? 1 : rawLine.trim().length;
      lineCount += math.max(1, (length / charsPerLine).ceil());
    }
    return math.max(fontSize * lineHeight, lineCount * fontSize * lineHeight).toDouble();
  }

  void _drawIcon({
    required PdfPage page,
    required Map<String, dynamic> element,
    required Rect rect,
    required Map<String, dynamic> style,
    required double fontScale,
  }) {
    final String iconName = element['iconName']?.toString() ?? 'weblink';
    final String iconText = <String, String>{
          'phone': '☎',
          'email': '@',
          'location': '⌖',
          'github': 'GH',
          'linkedin': 'in',
          'weblink': '↗',
        }[iconName] ??
        '↗';
    page.graphics.drawString(
      iconText,
      _fontFor(weight: 700, size: _asDouble(style['fontSize'], 13) * fontScale),
      brush: _brush(style['color']?.toString()) ?? PdfBrushes.black,
      bounds: rect,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
  }

  Map<String, dynamic> _layoutFromTemplate(CvTemplateModel template) {
    if (template.schema.layout.isNotEmpty) return template.schema.layout;
    if (template.schema.designJson.isNotEmpty) return template.schema.designJson;
    return <String, dynamic>{};
  }

  Map<String, dynamic> _themedStyle(
    Map<String, dynamic> style, {
    required CvDocumentModel document,
    required CvTemplateModel template,
  }) {
    if (style.isEmpty) return style;

    final Map<String, dynamic> themedStyle = Map<String, dynamic>.from(style);
    themedStyle['color'] = _resolveThemeColor(
      value: themedStyle['color'],
      role: themedStyle['colorRole'],
      document: document,
      template: template,
    );
    themedStyle['backgroundColor'] = _resolveThemeColor(
      value: themedStyle['backgroundColor'],
      role: themedStyle['backgroundColorRole'],
      document: document,
      template: template,
    );
    themedStyle['borderColor'] = _resolveThemeColor(
      value: themedStyle['borderColor'],
      role: themedStyle['borderColorRole'],
      document: document,
      template: template,
    );
    return themedStyle;
  }

  String? _resolveThemeColor({
    required dynamic value,
    required dynamic role,
    required CvDocumentModel document,
    required CvTemplateModel template,
  }) {
    final String roleText = role?.toString().trim().toLowerCase() ?? '';
    if (roleText == 'primary') return document.themeColor;
    if (roleText == 'accent') return document.accentColor;

    final String? color = _nonEmptyString(value);
    if (color == null) return null;
    if (_sameHex(color, template.primaryColor)) return document.themeColor;
    if (_sameHex(color, template.accentColor)) return document.accentColor;
    return color;
  }

  bool _sameHex(String first, String second) =>
      first.replaceAll('#', '').trim().toLowerCase() ==
      second.replaceAll('#', '').trim().toLowerCase();

  List<_PositionedLayoutElement> _layoutTopLevelElements({
    required List<Map<String, dynamic>> elements,
    required CvDocumentModel document,
    required CvTemplateModel template,
  }) {
    final List<_PositionedLayoutElement> placed = <_PositionedLayoutElement>[];
    for (final Map<String, dynamic> element in _flowSortedElements(elements)) {
      final bool visible = _shouldRenderTopLevelElement(
        element: element,
        document: document,
        template: template,
      );
      final double originalHeight = _effectiveHeight(element);
      final double height = visible
          ? _renderHeightForTopLevelElement(
              element: element,
              document: document,
              template: template,
            )
          : 0;
      placed.add(
        _positionElementWithReflow(
          element: element,
          placed: placed,
          visible: visible,
          height: height,
          originalHeight: originalHeight,
          width: _effectiveWidth(element),
          originalX: _asDouble(element['x'], 0),
          originalY: _asDouble(element['y'], 0),
        ),
      );
    }
    return placed;
  }

  _PositionedLayoutElement _positionElementWithReflow({
    required Map<String, dynamic> element,
    required List<_PositionedLayoutElement> placed,
    required bool visible,
    required double height,
    required double originalHeight,
    required double width,
    required double originalX,
    required double originalY,
  }) {
    double nextY = originalY;
    for (final _PositionedLayoutElement previous in placed) {
      if (!_horizontalOverlap(originalX, width, previous.originalX, previous.width)) {
        continue;
      }
      if (previous.originalY + previous.originalHeight > originalY + 0.01) {
        continue;
      }
      final double originalGap = math.max(
        0,
        originalY - (previous.originalY + previous.originalHeight),
      );
      nextY = math.max(nextY == originalY ? -double.infinity : nextY, previous.sourceY + previous.height + originalGap);
    }
    if (nextY == -double.infinity) nextY = originalY;

    return _PositionedLayoutElement(
      element: element,
      sourceX: originalX,
      sourceY: nextY,
      width: width,
      height: math.max(0, height),
      originalX: originalX,
      originalY: originalY,
      originalHeight: originalHeight,
      visible: visible,
    );
  }

  bool _horizontalOverlap(
    double firstX,
    double firstWidth,
    double secondX,
    double secondWidth,
  ) {
    return firstX < secondX + secondWidth && secondX < firstX + firstWidth;
  }

  bool _shouldRenderTopLevelElement({
    required Map<String, dynamic> element,
    required CvDocumentModel document,
    required CvTemplateModel template,
  }) {
    if (element['type']?.toString() != 'section') {
      if (!_shouldCollapseWhenEmpty(element)) return true;
      final String value = _elementValue(
        element: element,
        document: document,
        template: template,
        parentSectionKey: null,
      );
      return value.trim().isNotEmpty;
    }

    final String sectionKey =
        _asMap(element['contentBinding'])['sectionKey']?.toString() ?? '';
    final CvTemplateSectionModel? section = _sectionByKey(template, sectionKey);
    if (section == null || section.fields.isEmpty) return true;
    final CvTemplateFieldModel? dynamicField = _dynamicItemsFieldForSection(section);
    if (dynamicField != null) {
      return _dynamicItemValuesForSection(
        document: document,
        section: section,
        dynamicField: dynamicField,
      ).isNotEmpty;
    }

    final Map<String, dynamic> sectionData = _sectionData(document.formData, section.key);
    for (final CvTemplateFieldModel field in section.fields) {
      final dynamic rawValue = _valueByCandidateKeys(sectionData, <String>[field.key, field.label]);
      if (_displayValue(rawValue, field.type).trim().isNotEmpty) return true;
    }
    return false;
  }

  double _renderHeightForTopLevelElement({
    required Map<String, dynamic> element,
    required CvDocumentModel document,
    required CvTemplateModel template,
  }) {
    if (element['type']?.toString() == 'section') {
      return _estimatedSectionHeight(
        element: element,
        document: document,
        template: template,
      );
    }

    if (!_canAutoGrow(element)) return _effectiveHeight(element);

    return _estimatedElementHeight(
      element: element,
      document: document,
      template: template,
      parentSectionKey: null,
      availableWidth: _effectiveWidth(element),
      allowShrink: true,
    );
  }

  double _estimatedSectionHeight({
    required Map<String, dynamic> element,
    required CvDocumentModel document,
    required CvTemplateModel template,
  }) {
    final double originalHeight = _effectiveHeight(element);
    final String sectionKey =
        _asMap(element['contentBinding'])['sectionKey']?.toString() ?? '';
    final CvTemplateSectionModel? section = _sectionByKey(template, sectionKey);
    final Map<String, dynamic> designerJson = _asMap(
      element['sectionDesignerJson'] ?? section?.designerJson,
    );
    final Map<String, dynamic> canvas = _asMap(designerJson['canvas']);
    final List<Map<String, dynamic>> children = _asListOfMaps(designerJson['elements']);
    if (children.isEmpty) return originalHeight;

    final double canvasWidth = _asDouble(canvas['width'], _effectiveWidth(element));
    final double canvasHeight = _asDouble(canvas['height'], originalHeight);
    final CvTemplateFieldModel? dynamicField = _dynamicItemsFieldForSection(section);
    final List<Map<String, dynamic>> dynamicItems = _dynamicItemValuesForSection(
      document: document,
      section: section,
      dynamicField: dynamicField,
    );
    if (dynamicField != null) {
      if (dynamicItems.isEmpty) return 0;
      double totalHeight = 0;
      for (final Map<String, dynamic> itemData in dynamicItems) {
        final List<_PositionedLayoutElement> itemLayout = _layoutSectionChildren(
          children: children,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
          sectionWidth: _effectiveWidth(element),
          sectionHeight: originalHeight,
          document: document,
          template: template,
          parentSectionKey: sectionKey,
          dynamicItemData: itemData,
        );
        totalHeight += _positionedBottom(itemLayout);
      }
      totalHeight += math.max(0, dynamicField.repeatGap).toDouble() * math.max(0, dynamicItems.length - 1).toDouble();
      return totalHeight;
    }

    final List<_PositionedLayoutElement> childLayout = _layoutSectionChildren(
      children: children,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      sectionWidth: _effectiveWidth(element),
      sectionHeight: originalHeight,
      document: document,
      template: template,
      parentSectionKey: sectionKey,
    );
    return _positionedBottom(childLayout);
  }

  List<_PositionedLayoutElement> _layoutSectionChildren({
    required List<Map<String, dynamic>> children,
    required double canvasWidth,
    required double canvasHeight,
    required double sectionWidth,
    required double sectionHeight,
    required CvDocumentModel document,
    required CvTemplateModel template,
    required String parentSectionKey,
    Map<String, dynamic>? dynamicItemData,
  }) {
    final double scaleX = sectionWidth / math.max(1, canvasWidth);
    final double scaleY = sectionHeight / math.max(1, canvasHeight);
    final List<_PositionedLayoutElement> placed = <_PositionedLayoutElement>[];

    for (final Map<String, dynamic> child in _flowSortedElements(children)) {
      final double originalX = _asDouble(child['x'], 0) * scaleX;
      final double originalY = _asDouble(child['y'], 0) * scaleY;
      final double width = _effectiveWidth(child) * scaleX;
      final double originalHeight = _effectiveHeight(child) * scaleY;
      final String childValue = _elementValue(
        element: child,
        document: document,
        template: template,
        parentSectionKey: parentSectionKey,
        dynamicItemData: dynamicItemData,
      );
      final bool collapsesEmptyField = child['isField'] == true &&
          childValue.trim().isEmpty &&
          _shouldCollapseWhenEmpty(child);
      final bool visible = !collapsesEmptyField;
      final double height = visible
          ? _estimatedChildHeight(
              element: child,
              document: document,
              template: template,
              parentSectionKey: parentSectionKey,
              availableWidth: width,
              originalHeight: originalHeight,
              dynamicItemData: dynamicItemData,
            )
          : 0;

      placed.add(
        _positionElementWithReflow(
          element: child,
          placed: placed,
          visible: visible,
          height: height,
          originalHeight: originalHeight,
          width: width,
          originalX: originalX,
          originalY: originalY,
        ),
      );
    }

    return placed;
  }

  double _estimatedChildHeight({
    required Map<String, dynamic> element,
    required CvDocumentModel document,
    required CvTemplateModel template,
    required String parentSectionKey,
    required double availableWidth,
    required double originalHeight,
    Map<String, dynamic>? dynamicItemData,
  }) {
    if (!_canAutoGrow(element)) return originalHeight;
    return _estimatedElementHeight(
      element: element,
      document: document,
      template: template,
      parentSectionKey: parentSectionKey,
      availableWidth: availableWidth,
      dynamicItemData: dynamicItemData,
      allowShrink: true,
    );
  }

  double _positionedBottom(List<_PositionedLayoutElement> items) {
    double bottom = 0;
    for (final _PositionedLayoutElement item in items) {
      if (!item.visible) continue;
      bottom = math.max(bottom, item.sourceY + item.height);
    }
    return bottom;
  }

  bool _canAutoGrow(Map<String, dynamic> element) {
    final Map<String, dynamic> binding = _asMap(element['contentBinding']);
    final Map<String, dynamic> flow = _asMap(element['contentFlow']);
    final String type = element['type']?.toString() ?? '';
    return binding['autoHeight'] == true ||
        flow['autoHeight'] == true ||
        element['autoHeight'] == true ||
        type == 'text' ||
        type == 'textarea' ||
        type == 'list' ||
        type == 'dynamicItems';
  }

  bool _shouldCollapseWhenEmpty(Map<String, dynamic> element) {
    final Map<String, dynamic> binding = _asMap(element['contentBinding']);
    final Map<String, dynamic> flow = _asMap(element['contentFlow']);
    return binding['collapseWhenEmpty'] == true ||
        flow['collapseWhenEmpty'] == true ||
        element['collapseWhenEmpty'] == true;
  }

  double _estimatedElementHeight({
    required Map<String, dynamic> element,
    required CvDocumentModel document,
    required CvTemplateModel template,
    required String? parentSectionKey,
    required double availableWidth,
    bool allowShrink = false,
    Map<String, dynamic>? dynamicItemData,
  }) {
    final String type = element['type']?.toString() ?? 'text';
    final double originalHeight = _effectiveHeight(element);
    if (type == 'rectangle' || type == 'circle' || _isLine(type) || type == 'icon') {
      return originalHeight;
    }

    final String value = _elementValue(
      element: element,
      document: document,
      template: template,
      parentSectionKey: parentSectionKey,
      dynamicItemData: dynamicItemData,
    );
    if (value.trim().isEmpty) return allowShrink ? 0 : originalHeight;

    final double fontSize = _asDouble(_asMap(element['style'])['fontSize'], 12);
    final double lineHeight = _asDouble(_asMap(element['style'])['lineHeight'], 1.25);
    final double usableWidth = math.max(24, availableWidth).toDouble();
    final int charsPerLine = math.max(8, (usableWidth / math.max(4, fontSize * 0.52)).floor());
    final List<String> rawLines = _cleanText(value).split('\n');
    int lineCount = 0;
    for (final String rawLine in rawLines) {
      final int length = rawLine.trim().isEmpty ? 1 : rawLine.trim().length;
      lineCount += math.max(1, (length / charsPerLine).ceil());
    }
    final double estimated = lineCount * fontSize * lineHeight + 8;
    return allowShrink ? math.max(8, estimated) : math.max(originalHeight, estimated);
  }

  Rect _elementRect({
    required Map<String, dynamic> element,
    required double sourceHeight,
    required int pageIndex,
    required double scaleX,
    required double scaleY,
  }) {
    return Rect.fromLTWH(
      _asDouble(element['x'], 0) * scaleX,
      (_asDouble(element['y'], 0) - pageIndex * sourceHeight) * scaleY,
      _effectiveWidth(element) * scaleX,
      _effectiveHeight(element) * scaleY,
    );
  }

  double _effectiveWidth(Map<String, dynamic> element) {
    final String type = element['type']?.toString() ?? '';
    if (type == 'verticalLine') return _asDouble(_asMap(element['style'])['borderWidth'], 2);
    return _asDouble(element['width'], 0);
  }

  double _effectiveHeight(Map<String, dynamic> element) {
    final String type = element['type']?.toString() ?? '';
    if (type == 'horizontalLine' || type == 'line') {
      return _asDouble(_asMap(element['style'])['borderWidth'], 2);
    }
    return _asDouble(element['height'], 0);
  }

  String _elementValue({
    required Map<String, dynamic> element,
    required CvDocumentModel document,
    required CvTemplateModel template,
    required String? parentSectionKey,
    Map<String, dynamic>? dynamicItemData,
  }) {
    final Map<String, dynamic> binding = _asMap(element['contentBinding']);
    final String bindingMode = binding['mode']?.toString() ?? '';
    final String? sectionKey =
        _nonEmptyString(binding['sectionKey']) ?? parentSectionKey;
    final String? fieldKey = _nonEmptyString(binding['fieldKey']) ??
        _nonEmptyString(element['fieldKey']);
    final bool isField = element['isField'] == true;
    final bool isDynamicInput = bindingMode == 'dynamic' || isField;

    if (!isDynamicInput || fieldKey == null) {
      return _staticElementValue(element);
    }

    if (dynamicItemData != null) {
      final dynamic itemValue = _valueByCandidateKeys(dynamicItemData, <String>[
        fieldKey,
        if (_nonEmptyString(element['label']) != null) _nonEmptyString(element['label'])!,
      ]);
      if (itemValue != null) return _displayValue(itemValue, null);
      return _staticElementValue(element);
    }

    final bool hasRegisteredField = _hasRegisteredField(
      template: template,
      sectionKey: sectionKey,
      fieldKey: fieldKey,
      element: element,
    );
    if (!hasRegisteredField) {
      return _staticElementValue(element);
    }

    final dynamic rawValue = _findBoundValue(
      document: document,
      template: template,
      sectionKey: sectionKey,
      fieldKey: fieldKey,
      element: element,
    );

    return _displayValue(rawValue, null);
  }

  dynamic _findBoundValue({
    required CvDocumentModel document,
    required CvTemplateModel template,
    required String? sectionKey,
    required String fieldKey,
    required Map<String, dynamic> element,
  }) {
    final List<String> sectionCandidates = <String>[
      if (sectionKey != null) sectionKey,
    ];
    final List<String> fieldCandidates = <String>[
      fieldKey,
      if (_nonEmptyString(element['label']) != null) _nonEmptyString(element['label'])!,
    ];

    for (final CvTemplateSectionModel section in template.schema.sections) {
      if (sectionKey != null && !_sameKey(section.key, sectionKey)) continue;
      sectionCandidates.add(section.key);
      for (final CvTemplateFieldModel field in section.fields) {
        if (_sameKey(field.key, fieldKey) || _sameKey(field.label, fieldKey)) {
          fieldCandidates.add(field.key);
          fieldCandidates.add(field.label);
        }
      }
    }

    final List<Map<String, dynamic>> sectionDataCandidates = <Map<String, dynamic>>[];
    for (final String key in sectionCandidates) {
      final Map<String, dynamic>? data = _sectionDataOrNull(document.formData, key);
      if (data != null) sectionDataCandidates.add(data);
    }
    if (sectionDataCandidates.isEmpty && sectionKey == null) {
      for (final dynamic value in document.formData.values) {
        final Map<String, dynamic> data = _asMap(value);
        if (data.isNotEmpty) sectionDataCandidates.add(data);
      }
    }

    for (final Map<String, dynamic> sectionData in sectionDataCandidates) {
      final dynamic value = _valueByCandidateKeys(sectionData, fieldCandidates);
      if (value != null) return value;
    }

    return _valueByCandidateKeys(document.formData, fieldCandidates);
  }

  dynamic _valueByCandidateKeys(
    Map<String, dynamic> data,
    List<String> candidateKeys,
  ) {
    for (final String key in candidateKeys) {
      if (data.containsKey(key)) return data[key];
    }

    final Set<String> normalizedCandidates = candidateKeys
        .map(_normalizeKey)
        .where((String item) => item.isNotEmpty)
        .toSet();
    if (normalizedCandidates.isEmpty) return null;

    for (final MapEntry<String, dynamic> entry in data.entries) {
      if (normalizedCandidates.contains(_normalizeKey(entry.key))) {
        return entry.value;
      }
    }

    return null;
  }

  bool _hasRegisteredField({
    required CvTemplateModel template,
    required String? sectionKey,
    required String fieldKey,
    required Map<String, dynamic> element,
  }) {
    final String elementLabel = element['label']?.toString() ?? '';
    for (final CvTemplateSectionModel section in template.schema.sections) {
      if (sectionKey != null && !_sameKey(section.key, sectionKey)) continue;
      for (final CvTemplateFieldModel field in section.fields) {
        if (_sameKey(field.key, fieldKey) ||
            _sameKey(field.label, fieldKey) ||
            (elementLabel.isNotEmpty && _sameKey(field.label, elementLabel))) {
          return true;
        }
        for (final CvTemplateDynamicItemFieldModel itemField in field.itemFields) {
          if (_sameKey(itemField.key, fieldKey) ||
              _sameKey(itemField.label, fieldKey) ||
              (elementLabel.isNotEmpty && _sameKey(itemField.label, elementLabel))) {
            return true;
          }
        }
      }
    }
    return false;
  }

  String _staticElementValue(Map<String, dynamic> element) {
    for (final String key in <String>[
      'previewValue',
      'placeholder',
      'staticValue',
      'text',
      'value',
      'content',
      'label',
    ]) {
      final String? value = _nonEmptyString(element[key]);
      if (value != null) return value;
    }

    return '';
  }

  String _displayValue(dynamic rawValue, String? fieldType) {
    if (rawValue == null) return '';
    if (rawValue is List) {
      return rawValue
          .map((dynamic item) => item.toString().trim())
          .where((String item) => item.isNotEmpty)
          .map((String item) => '• $item')
          .join('\n');
    }
    if (rawValue is Map) {
      final dynamic rawItems = rawValue['items'];
      final String listStyle = rawValue['listStyle']?.toString() ?? 'bullet';
      if (rawItems is List) {
        return rawItems
            .map((dynamic item) => item.toString().trim())
            .where((String item) => item.isNotEmpty)
            .toList(growable: false)
            .asMap()
            .entries
            .map((MapEntry<int, String> entry) => listStyle == 'number'
                ? '${entry.key + 1}. ${entry.value}'
                : '• ${entry.value}')
            .join('\n');
      }

      return rawValue.values
          .map((dynamic item) => item.toString().trim())
          .where((String item) => item.isNotEmpty)
          .join('\n');
    }
    return rawValue.toString().trim();
  }

  bool _isPhotoElement(
    String type,
    Map<String, dynamic> element,
    CvTemplateModel template,
  ) {
    if (type == 'circle') return true;
    final String fieldKey = _asMap(element['contentBinding'])['fieldKey']?.toString() ??
        element['fieldKey']?.toString() ??
        '';
    for (final CvTemplateSectionModel section in template.schema.sections) {
      for (final CvTemplateFieldModel field in section.fields) {
        if (_sameKey(field.key, fieldKey) && _isPhotoFieldType(field.type)) return true;
      }
    }
    return false;
  }

  bool _isPhotoFieldType(String value) {
    final String type = value.trim().toLowerCase();
    return <String>{'photourl', 'photo_url', 'imageurl', 'photo'}.contains(type);
  }

  bool _isLine(String type) =>
      type == 'horizontalLine' || type == 'verticalLine' || type == 'line';

  CvTemplateSectionModel? _sectionByKey(CvTemplateModel template, String key) {
    for (final CvTemplateSectionModel section in template.schema.sections) {
      if (_sameKey(section.key, key)) return section;
    }
    return null;
  }

  bool _isDynamicItemsType(String value) {
    final String type = value.trim().toLowerCase();
    return type == 'dynamicitems' ||
        type == 'dynamic_items' ||
        type == 'repeatable' ||
        type == 'repeatableitems';
  }

  CvTemplateFieldModel? _dynamicItemsFieldForSection(
    CvTemplateSectionModel? section,
  ) {
    if (section == null) return null;
    for (final CvTemplateFieldModel field in section.fields) {
      if (_isDynamicItemsType(field.type)) return field;
    }
    return null;
  }

  List<Map<String, dynamic>> _dynamicItemValuesForSection({
    required CvDocumentModel document,
    required CvTemplateSectionModel? section,
    required CvTemplateFieldModel? dynamicField,
  }) {
    if (section == null || dynamicField == null) return <Map<String, dynamic>>[];
    final Map<String, dynamic> sectionData = _sectionData(document.formData, section.key);
    dynamic rawItems = sectionData[dynamicField.key];
    rawItems ??= sectionData[section.key];
    rawItems ??= _valueByCandidateKeys(sectionData, <String>[
      dynamicField.key,
      dynamicField.label,
      section.key,
      section.title,
    ]);
    if (rawItems is! List) return <Map<String, dynamic>>[];
    return rawItems
        .map(_asMap)
        .where((Map<String, dynamic> item) => item.isNotEmpty)
        .toList(growable: false);
  }

  Map<String, dynamic> _sectionData(Map<String, dynamic> formData, String sectionKey) {
    return _sectionDataOrNull(formData, sectionKey) ?? <String, dynamic>{};
  }

  Map<String, dynamic>? _sectionDataOrNull(
    Map<String, dynamic> formData,
    String sectionKey,
  ) {
    final dynamic rawSection = formData[sectionKey];
    if (rawSection is Map<String, dynamic>) return rawSection;
    if (rawSection is Map) return Map<String, dynamic>.from(rawSection);

    final String normalizedSectionKey = _normalizeKey(sectionKey);
    for (final MapEntry<String, dynamic> entry in formData.entries) {
      if (_normalizeKey(entry.key) != normalizedSectionKey) continue;
      final Map<String, dynamic> data = _asMap(entry.value);
      if (data.isNotEmpty) return data;
    }

    return null;
  }

  Future<Uint8List?> _loadImageBytes(String url) async {
    if (_imageCache.containsKey(url)) return _imageCache[url];
    final HttpClient client = HttpClient();
    try {
      final HttpClientRequest request = await client.getUrl(Uri.parse(url));
      final HttpClientResponse response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final BytesBuilder bytesBuilder = BytesBuilder(copy: false);
      await for (final List<int> chunk in response) {
        bytesBuilder.add(chunk);
      }
      final Uint8List bytes = bytesBuilder.takeBytes();
      _imageCache[url] = bytes;
      return bytes;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  void _drawPageBackground({
    required PdfPage page,
    required Size pageSize,
    required String backgroundColor,
  }) {
    final PdfBrush? brush = _brush(backgroundColor);
    if (brush == null) return;
    page.graphics.drawRectangle(
      brush: brush,
      bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
    );
  }

  PdfFont _fontFor({required int weight, required double size}) {
    if (weight >= 700) {
      return PdfStandardFont(
        PdfFontFamily.helvetica,
        size,
        style: PdfFontStyle.bold,
      );
    }

    return PdfStandardFont(PdfFontFamily.helvetica, size);
  }

  PdfPen? _borderPen(Map<String, dynamic> style, {double fontScale = 1}) {
    final double width = _asDouble(style['borderWidth'], 0) * fontScale;
    if (width <= 0) return null;
    final PdfColor? color = _nullablePdfColor(style['borderColor']?.toString());
    if (color == null) return null;
    return PdfPen(color, width: math.max(0.25, width));
  }

  PdfBrush? _brush(String? hexValue) {
    final PdfColor? color = _nullablePdfColor(hexValue);
    return color == null ? null : PdfSolidBrush(color);
  }

  PdfColor? _nullablePdfColor(String? hexValue) {
    if (hexValue == null || hexValue.trim().isEmpty) return null;
    if (hexValue.trim().toLowerCase() == 'transparent') return null;
    return _hexToPdfColor(hexValue);
  }

  PdfColor _hexToPdfColor(String hexValue) {
    final String normalizedHex = hexValue.replaceAll('#', '').trim();
    if (normalizedHex.length != 6) return PdfColor(0, 107, 63);
    final int? red = int.tryParse(normalizedHex.substring(0, 2), radix: 16);
    final int? green = int.tryParse(normalizedHex.substring(2, 4), radix: 16);
    final int? blue = int.tryParse(normalizedHex.substring(4, 6), radix: 16);
    return PdfColor(red ?? 0, green ?? 107, blue ?? 63);
  }

  PdfTextAlignment _textAlignment(String? value) => value == 'center'
      ? PdfTextAlignment.center
      : value == 'right'
          ? PdfTextAlignment.right
          : value == 'justify'
              ? PdfTextAlignment.justify
              : PdfTextAlignment.left;

  double _lineSpacing(Map<String, dynamic> style, double fontScale) {
    final double lineHeight = _asDouble(style['lineHeight'], 1.2);
    final double fontSize = _asDouble(style['fontSize'], 12) * fontScale;
    return ((lineHeight - 1).clamp(0, 2) as num).toDouble() * fontSize;
  }

  Size _pdfPageSize(String pageSize) => pageSize.toLowerCase() == 'letter'
      ? const Size(_letterWidth, _letterHeight)
      : const Size(_a4Width, _a4Height);

  List<Map<String, dynamic>> _sortedElements(List<Map<String, dynamic>> items) {
    final List<MapEntry<int, Map<String, dynamic>>> indexedItems =
        <MapEntry<int, Map<String, dynamic>>>[
      for (int index = 0; index < items.length; index += 1)
        MapEntry<int, Map<String, dynamic>>(index, items[index]),
    ];

    indexedItems.sort(
      (MapEntry<int, Map<String, dynamic>> first,
          MapEntry<int, Map<String, dynamic>> second) {
        final int zIndexCompare = _asDouble(first.value['zIndex'], 0)
            .compareTo(_asDouble(second.value['zIndex'], 0));
        return zIndexCompare != 0
            ? zIndexCompare
            : first.key.compareTo(second.key);
      },
    );

    return indexedItems
        .map((MapEntry<int, Map<String, dynamic>> entry) => entry.value)
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _flowSortedElements(List<Map<String, dynamic>> items) {
    return items.toList()
      ..sort((Map<String, dynamic> first, Map<String, dynamic> second) {
        final int yCompare = _asDouble(first['y'], 0).compareTo(_asDouble(second['y'], 0));
        if (yCompare != 0) return yCompare;
        final int xCompare = _asDouble(first['x'], 0).compareTo(_asDouble(second['x'], 0));
        if (xCompare != 0) return xCompare;
        return _asDouble(first['zIndex'], 0).compareTo(_asDouble(second['zIndex'], 0));
      });
  }

  bool _sameKey(String first, String second) => _normalizeKey(first) == _normalizeKey(second);

  String _normalizeKey(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  String? _nonEmptyString(dynamic value) {
    if (value == null) return null;
    final String normalizedValue = value.toString().trim();
    return normalizedValue.isEmpty ? null : normalizedValue;
  }

  Map<String, dynamic> _asMap(dynamic value) => value is Map<String, dynamic>
      ? value
      : value is Map
          ? Map<String, dynamic>.from(value)
          : <String, dynamic>{};

  List<Map<String, dynamic>> _asListOfMaps(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  double _asDouble(dynamic value, double fallback) => value is num
      ? value.toDouble()
      : value is String
          ? double.tryParse(value) ?? fallback
          : fallback;

  String _cleanText(String value) {
    return value
        .replaceAll(RegExp(r'<br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }
}

class _PositionedLayoutElement {
  const _PositionedLayoutElement({
    required this.element,
    required this.sourceX,
    required this.sourceY,
    required this.width,
    required this.height,
    required this.originalX,
    required this.originalY,
    required this.originalHeight,
    required this.visible,
  });

  final Map<String, dynamic> element;
  final double sourceX;
  final double sourceY;
  final double width;
  final double height;
  final double originalX;
  final double originalY;
  final double originalHeight;
  final bool visible;
}
