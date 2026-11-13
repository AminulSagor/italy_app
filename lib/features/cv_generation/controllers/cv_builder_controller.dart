import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_error_handler.dart';
import '../helpers/cv_builder_localization.dart';
import '../models/cv_template_model.dart';
import '../models/resume_studio_models.dart';
import '../services/resume_studio_api_service.dart';
import '../views/cv_preview_view.dart';
import 'cv_preview_controller.dart';

class CvBuilderController extends GetxController {
  CvBuilderController({
    required ResumeStudioApiService apiService,
    required CvBuilderContractModel contract,
    required CvFieldSchema initialSchema,
    CvTemplateModel? initialTemplate,
    ResumeDocumentModel? initialDocument,
    CvAccessModel? accessAtOpen,
  }) : _apiService = apiService,
       contract = contract,
       _schema = initialTemplate?.fieldSchema ?? initialSchema,
       _initialDocument = initialDocument,
       accessAtOpen = accessAtOpen,
       selectedTemplate = Rxn<CvTemplateModel>(initialTemplate);

  final ResumeStudioApiService _apiService;
  final ImagePicker _imagePicker = ImagePicker();

  final CvBuilderContractModel contract;
  CvFieldSchema _schema;
  final ResumeDocumentModel? _initialDocument;
  final CvAccessModel? accessAtOpen;

  final Rxn<CvTemplateModel> selectedTemplate;
  final RxBool isPreparing = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isRendering = false.obs;
  final RxBool isUploadingPhoto = false.obs;
  final RxBool hasUnsavedChanges = false.obs;
  final RxString saveError = ''.obs;
  final RxString localPhotoName = ''.obs;
  final RxBool creationAccessConsumed = false.obs;

  final Map<String, List<String>> _aiSuggestions = <String, List<String>>{};
  final Set<String> _aiSuggestionLoading = <String>{};
  final Map<String, String> _lastAiSuggestionSignatures = <String, String>{};

  final Map<String, dynamic> _data = <String, dynamic>{};

  ResumeDocumentModel? _document;
  Future<void>? _documentCreationFuture;
  Timer? _autosaveTimer;
  Timer? _proactiveAiTimer;
  bool _saveQueued = false;
  bool _disposed = false;
  int _changeSerial = 0;

  String title = 'cvb_my_cv'.tr;

  CvFieldSchema get schema => _schema;
  String? get documentId => _document?.id;
  bool get isEditingExistingDocument => _initialDocument != null;
  bool get firstPdfWillConsumeAccess => !creationAccessConsumed.value;

  @override
  void onInit() {
    super.onInit();
    _documentCreationFuture = _prepareDocument();
  }

  Future<void> _prepareDocument() async {
    isPreparing.value = true;
    saveError.value = '';

    try {
      final ResumeDocumentModel? existing = _initialDocument;
      if (existing != null) {
        _document = existing;
        title = existing.title.trim().isEmpty
            ? 'cvb_my_cv'.tr
            : existing.title.trim();
        _data
          ..clear()
          ..addAll(_deepCopyMap(existing.data));
        creationAccessConsumed.value = existing.hasConsumedCreationAccess;
        _scheduleProactiveAiSuggestions();
        return;
      }

      final ResumeDocumentModel document = await _apiService.createDocument(
        title: title,
        templateId: selectedTemplate.value?.id,
        data: _snapshotData(),
      );

      if (_disposed) return;
      _document = document;
      title = document.title.trim().isEmpty
          ? 'cvb_my_cv'.tr
          : document.title.trim();
      _data
        ..clear()
        ..addAll(_deepCopyMap(document.data));
      creationAccessConsumed.value = document.hasConsumedCreationAccess;
      update(<String>['form']);
      _scheduleProactiveAiSuggestions();

      if (hasUnsavedChanges.value) {
        _scheduleAutosave();
      }
    } catch (error) {
      saveError.value = ApiErrorHandler.getErrorMessage(error);
    } finally {
      if (!_disposed) isPreparing.value = false;
    }
  }

  void setTitle(String value) {
    title = value.trim().isEmpty ? 'cvb_my_cv'.tr : value.trim();
    _markDirty();
  }

  dynamic fieldValue(
    CvSectionDefinition section,
    CvFieldDefinition field, {
    int? itemIndex,
  }) {
    if (section.isCollectionSection) {
      final List<Map<String, dynamic>> items = collectionItems(section.key);
      if (itemIndex == null || itemIndex < 0 || itemIndex >= items.length) {
        return null;
      }
      return items[itemIndex][field.leafKey];
    }

    if (section.key == 'personal') {
      final dynamic rawPersonal = _data['personal'];
      if (rawPersonal is! Map) return null;
      return rawPersonal[field.leafKey];
    }

    return _data[field.key];
  }

  void setFieldValue(
    CvSectionDefinition section,
    CvFieldDefinition field,
    dynamic value, {
    int? itemIndex,
  }) {
    if (section.isCollectionSection) {
      final List<Map<String, dynamic>> items = _mutableCollection(section.key);
      if (itemIndex == null || itemIndex < 0 || itemIndex >= items.length) {
        return;
      }
      final Map<String, dynamic> item = items[itemIndex];
      _writeValue(item, field.leafKey, value);

      final String? dependentDateKey = _dependentDateKeyForToggle(
        section.key,
        field.leafKey,
      );
      if (dependentDateKey != null && value == true) {
        // Keep persisted data canonical: when a user marks an item as current
        // (or non-expiring), its dependent date is no longer applicable.
        item.remove(dependentDateKey);
      }
    } else if (section.key == 'personal') {
      final Map<String, dynamic> personal = _personalMap();
      _writeValue(personal, field.leafKey, value);
    } else {
      _writeValue(_data, field.key, value);
    }

    _markDirty();
    _scheduleProactiveAiSuggestions();

    if (_dependentDateKeyForToggle(section.key, field.leafKey) != null) {
      update(<String>['form']);
    }
  }

  bool isCollectionFieldVisible(
    CvSectionDefinition section,
    CvFieldDefinition field, {
    required int itemIndex,
  }) {
    final String? controllingToggle = _controllingToggleForDateField(
      section.key,
      field.leafKey,
    );
    if (controllingToggle == null) return true;

    final List<Map<String, dynamic>> items = collectionItems(section.key);
    if (itemIndex < 0 || itemIndex >= items.length) return true;
    return items[itemIndex][controllingToggle] != true;
  }

  List<CvFieldDefinition> visibleCollectionFields(
    CvSectionDefinition section, {
    required int itemIndex,
  }) {
    return section.visibleFields
        .where(
          (CvFieldDefinition field) =>
              isCollectionFieldVisible(section, field, itemIndex: itemIndex),
        )
        .toList(growable: false);
  }

  String? _dependentDateKeyForToggle(String sectionKey, String leafKey) {
    if (leafKey == 'isCurrent' &&
        <String>{'experience', 'education', 'projects'}.contains(sectionKey)) {
      return 'endDate';
    }
    if (sectionKey == 'certifications' && leafKey == 'doesNotExpire') {
      return 'expiryDate';
    }
    return null;
  }

  String? _controllingToggleForDateField(String sectionKey, String leafKey) {
    if (leafKey == 'endDate' &&
        <String>{'experience', 'education', 'projects'}.contains(sectionKey)) {
      return 'isCurrent';
    }
    if (sectionKey == 'certifications' && leafKey == 'expiryDate') {
      return 'doesNotExpire';
    }
    return null;
  }

  List<Map<String, dynamic>> collectionItems(String sectionKey) {
    final dynamic raw = _data[sectionKey];
    if (raw is! List) return const <Map<String, dynamic>>[];

    return raw
        .whereType<Map>()
        .map((Map item) => Map<String, dynamic>.from(item))
        .toList();
  }

  void addCollectionItem(CvSectionDefinition section) {
    final List<Map<String, dynamic>> items = _mutableCollection(section.key);
    final int maxItems = section.maxItems ?? 50;
    if (items.length >= maxItems) {
      Get.snackbar(
        'cvb_limit_reached'.tr,
        'cvb_limit_message'.trParams(<String, String>{
          'section': cvSectionLabel(section),
          'count': '$maxItems',
        }),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    items.add(<String, dynamic>{
      'id': 'local-${DateTime.now().microsecondsSinceEpoch}',
    });
    _markDirty();
    update(<String>['form']);
  }

  void removeCollectionItem(String sectionKey, int index) {
    final List<Map<String, dynamic>> items = _mutableCollection(sectionKey);
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    if (items.isEmpty) _data.remove(sectionKey);
    _markDirty();
    update(<String>['form']);
  }

  void reorderCollectionItem(String sectionKey, int oldIndex, int newIndex) {
    final List<Map<String, dynamic>> items = _mutableCollection(sectionKey);
    if (oldIndex < 0 || oldIndex >= items.length) return;
    if (newIndex > oldIndex) newIndex -= 1;
    if (newIndex < 0 || newIndex >= items.length) return;
    final Map<String, dynamic> item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    _markDirty();
    update(<String>['form']);
  }

  void setStringListField(
    CvSectionDefinition section,
    CvFieldDefinition field,
    List<String> values, {
    int? itemIndex,
  }) {
    final List<String> cleaned = values
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .take(field.maxItems ?? 50)
        .toList();
    setFieldValue(
      section,
      field,
      cleaned.isEmpty ? null : cleaned,
      itemIndex: itemIndex,
    );
  }

  Future<void> pickAndUploadPhoto(
    CvSectionDefinition section,
    CvFieldDefinition field,
  ) async {
    if (isUploadingPhoto.value) return;

    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (file == null) return;

    isUploadingPhoto.value = true;
    try {
      final String fileId = await _apiService.uploadResumePhoto(
        file: file,
        contract: contract,
      );
      localPhotoName.value = file.name;
      setFieldValue(section, field, fileId);
      update(<String>['form']);
    } catch (error) {
      Get.snackbar(
        'cvb_photo_upload_failed'.tr,
        ApiErrorHandler.getErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  List<String> aiSuggestionsFor(
    CvSectionDefinition section,
    CvFieldDefinition field, {
    int? itemIndex,
  }) {
    return List<String>.unmodifiable(
      _aiSuggestions[_aiSuggestionKey(section, field, itemIndex)] ??
          const <String>[],
    );
  }

  bool isAiSuggestionLoading(
    CvSectionDefinition section,
    CvFieldDefinition field, {
    int? itemIndex,
  }) {
    return _aiSuggestionLoading.contains(
      _aiSuggestionKey(section, field, itemIndex),
    );
  }

  Future<List<String>> requestAiSuggestions(
    CvSectionDefinition section,
    CvFieldDefinition field, {
    int? itemIndex,
    bool force = true,
  }) async {
    final String assistType = field.aiAssist?.trim() ?? '';
    if (assistType.isEmpty || !_hasEnoughAiContext(section, field, itemIndex)) {
      return const <String>[];
    }

    final String key = _aiSuggestionKey(section, field, itemIndex);
    if (_aiSuggestionLoading.contains(key)) {
      return aiSuggestionsFor(section, field, itemIndex: itemIndex);
    }

    final Map<String, dynamic> personal = _personalMap();
    final String targetRole = personal['jobTitle']?.toString().trim() ?? '';
    final List<String> skills = _stringList(_data['skills']);
    final List<String> experienceHighlights = _collectExperienceHighlights();
    final dynamic currentValue = fieldValue(
      section,
      field,
      itemIndex: itemIndex,
    );
    final List<String> existingItems = currentValue is List
        ? currentValue
              .map((dynamic item) => item.toString().trim())
              .where((String item) => item.isNotEmpty)
              .toList()
        : const <String>[];
    final String currentText = currentValue is String
        ? currentValue.trim()
        : '';

    String itemTitle = '';
    String organization = '';
    if (itemIndex != null && section.isCollectionSection) {
      final List<Map<String, dynamic>> items = collectionItems(section.key);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> item = items[itemIndex];
        if (section.key == 'experience') {
          itemTitle = item['position']?.toString().trim() ?? '';
          organization = item['company']?.toString().trim() ?? '';
        } else if (section.key == 'projects') {
          itemTitle = item['role']?.toString().trim() ?? '';
          organization = item['name']?.toString().trim() ?? '';
        }
      }
    }

    final String signature = <String>[
      assistType,
      _aiLanguage,
      targetRole,
      itemTitle,
      organization,
      currentText,
      existingItems.join('|'),
      skills.join('|'),
      experienceHighlights.join('|'),
    ].join('::');

    if (!force && _lastAiSuggestionSignatures[key] == signature) {
      return aiSuggestionsFor(section, field, itemIndex: itemIndex);
    }

    _lastAiSuggestionSignatures[key] = signature;
    _aiSuggestionLoading.add(key);
    update(<String>['form']);

    try {
      final ResumeAiSuggestionsModel result = await _apiService.suggestField(
        assistType: assistType,
        targetRole: targetRole,
        skills: skills,
        experienceHighlights: experienceHighlights,
        currentText: currentText,
        existingItems: existingItems,
        itemTitle: itemTitle,
        organization: organization,
        language: _aiLanguage,
      );

      final Set<String> existingNormalized = existingItems
          .map((String item) => item.toLowerCase())
          .toSet();
      final List<String> suggestions = result.suggestions
          .where(
            (String suggestion) =>
                !existingNormalized.contains(suggestion.trim().toLowerCase()),
          )
          .toList(growable: false);
      _aiSuggestions[key] = suggestions;
      return suggestions;
    } catch (_) {
      if (force) rethrow;
      return const <String>[];
    } finally {
      _aiSuggestionLoading.remove(key);
      if (!_disposed) update(<String>['form']);
    }
  }

  void includeAiSuggestion(
    CvSectionDefinition section,
    CvFieldDefinition field,
    String suggestion, {
    int? itemIndex,
    String? sourceSuggestion,
  }) {
    final String normalized = suggestion.trim();
    if (normalized.isEmpty) return;

    if (field.type == CvFieldType.tags ||
        field.type == CvFieldType.repeatable) {
      final dynamic raw = fieldValue(section, field, itemIndex: itemIndex);
      final List<String> values = raw is List
          ? raw
                .map((dynamic item) => item.toString().trim())
                .where((String item) => item.isNotEmpty)
                .toList()
          : <String>[];
      if (!values.any(
        (String item) => item.toLowerCase() == normalized.toLowerCase(),
      )) {
        values.add(normalized);
      }
      setStringListField(section, field, values, itemIndex: itemIndex);
    } else {
      setFieldValue(section, field, normalized, itemIndex: itemIndex);
    }

    excludeAiSuggestion(
      section,
      field,
      sourceSuggestion ?? normalized,
      itemIndex: itemIndex,
      rebuild: false,
    );
    update(<String>['form']);
  }

  void excludeAiSuggestion(
    CvSectionDefinition section,
    CvFieldDefinition field,
    String suggestion, {
    int? itemIndex,
    bool rebuild = true,
  }) {
    final String key = _aiSuggestionKey(section, field, itemIndex);
    final List<String> current = List<String>.from(
      _aiSuggestions[key] ?? const <String>[],
    );
    current.removeWhere((String item) => item == suggestion);
    if (current.isEmpty) {
      _aiSuggestions.remove(key);
    } else {
      _aiSuggestions[key] = current;
    }
    if (rebuild) update(<String>['form']);
  }

  String _aiSuggestionKey(
    CvSectionDefinition section,
    CvFieldDefinition field,
    int? itemIndex,
  ) {
    return '${section.key}:${itemIndex ?? -1}:${field.key}';
  }

  bool _hasEnoughAiContext(
    CvSectionDefinition section,
    CvFieldDefinition field,
    int? itemIndex,
  ) {
    final String assistType = field.aiAssist?.trim() ?? '';
    final String targetRole =
        _personalMap()['jobTitle']?.toString().trim() ?? '';
    final List<Map<String, dynamic>> experiences = collectionItems(
      'experience',
    );
    final bool hasExperienceRole = experiences.any(
      (Map<String, dynamic> item) =>
          item['position']?.toString().trim().isNotEmpty == true,
    );

    if (assistType == 'summary-suggestions') {
      return targetRole.isNotEmpty &&
          (_stringList(_data['skills']).isNotEmpty ||
              _collectExperienceHighlights().isNotEmpty ||
              hasExperienceRole);
    }
    if (assistType == 'technical-skill-suggestions') {
      return targetRole.isNotEmpty || hasExperienceRole;
    }

    if (itemIndex == null || !section.isCollectionSection) return false;
    final List<Map<String, dynamic>> items = collectionItems(section.key);
    if (itemIndex < 0 || itemIndex >= items.length) return false;
    final Map<String, dynamic> item = items[itemIndex];
    if (section.key == 'experience') {
      return item['position']?.toString().trim().isNotEmpty == true;
    }
    if (section.key == 'projects') {
      return item['role']?.toString().trim().isNotEmpty == true ||
          item['name']?.toString().trim().isNotEmpty == true;
    }
    return false;
  }

  List<String> _stringList(dynamic raw) {
    if (raw is! List) return const <String>[];
    return raw
        .map((dynamic item) => item.toString().trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _collectExperienceHighlights() {
    final List<String> highlights = <String>[];
    for (final Map<String, dynamic> item in collectionItems('experience')) {
      final String position = item['position']?.toString().trim() ?? '';
      final String company = item['company']?.toString().trim() ?? '';
      if (position.isNotEmpty) {
        highlights.add(company.isEmpty ? position : '$position at $company');
      }
      highlights.addAll(_stringList(item['bullets']));
      final String description = item['description']?.toString().trim() ?? '';
      if (description.isNotEmpty) highlights.add(description);
      if (highlights.length >= 12) break;
    }
    return highlights.take(12).toList(growable: false);
  }

  String get _aiLanguage {
    final String templateLocale =
        selectedTemplate.value?.locale?.trim().toLowerCase() ?? '';
    final String locale = templateLocale.isNotEmpty
        ? templateLocale
        : Get.locale?.languageCode.toLowerCase() ?? 'en';

    if (locale == 'it' ||
        locale.startsWith('it-') ||
        locale.startsWith('it_') ||
        locale.contains('ital')) {
      return 'Italian';
    }
    if (locale == 'bn' ||
        locale.startsWith('bn-') ||
        locale.startsWith('bn_') ||
        locale.contains('bengal') ||
        locale.contains('bangla')) {
      return 'Bengali';
    }
    return 'English';
  }

  void _scheduleProactiveAiSuggestions() {
    _proactiveAiTimer?.cancel();
    _proactiveAiTimer = Timer(
      const Duration(milliseconds: 1100),
      () => unawaited(_loadProactiveAiSuggestions()),
    );
  }

  Future<void> _loadProactiveAiSuggestions() async {
    if (_disposed || isPreparing.value) return;

    int requested = 0;
    for (final CvSectionDefinition section in _schema.visibleSections) {
      for (final CvFieldDefinition field in section.visibleFields) {
        if (!field.supportsAi) continue;

        if (section.isCollectionSection) {
          final List<Map<String, dynamic>> items = collectionItems(section.key);
          for (int index = 0; index < items.length; index += 1) {
            if (!_isEmpty(fieldValue(section, field, itemIndex: index)))
              continue;
            if (!_hasEnoughAiContext(section, field, index)) continue;
            await requestAiSuggestions(
              section,
              field,
              itemIndex: index,
              force: false,
            );
            requested += 1;
            if (requested >= 4 || _disposed) return;
          }
          continue;
        }

        if (!_isEmpty(fieldValue(section, field))) continue;
        if (!_hasEnoughAiContext(section, field, null)) continue;
        await requestAiSuggestions(section, field, force: false);
        requested += 1;
        if (requested >= 4 || _disposed) return;
      }
    }
  }

  Future<List<String>> requestSummarySuggestions() async {
    final String currentSummary = _data['summary']?.toString() ?? '';
    final Map<String, dynamic> personal = _personalMap();
    final String targetRole = personal['jobTitle']?.toString() ?? '';

    final List<String> skills = (_data['skills'] is List)
        ? (_data['skills'] as List)
              .map((dynamic item) => item.toString().trim())
              .where((String item) => item.isNotEmpty)
              .toList()
        : <String>[];

    final List<String> highlights = <String>[];
    for (final Map<String, dynamic> item in collectionItems('experience')) {
      final dynamic rawBullets = item['bullets'];
      if (rawBullets is List) {
        highlights.addAll(
          rawBullets
              .map((dynamic value) => value.toString().trim())
              .where((String value) => value.isNotEmpty),
        );
      }
      final String description = item['description']?.toString().trim() ?? '';
      if (description.isNotEmpty) highlights.add(description);
    }

    final ResumeSummarySuggestionsModel result = await _apiService
        .suggestSummary(
          currentSummary: currentSummary,
          targetRole: targetRole,
          skills: skills,
          experienceHighlights: highlights,
          language: _aiLanguage,
        );

    return result.suggestions;
  }

  void applySummarySuggestion(String summary) {
    CvSectionDefinition? section;
    for (final CvSectionDefinition item in _schema.sections) {
      if (item.key == 'summary') {
        section = item;
        break;
      }
    }
    if (section == null) return;

    CvFieldDefinition? field;
    for (final CvFieldDefinition item in section.fields) {
      if (item.key == 'summary') {
        field = item;
        break;
      }
    }
    if (field == null) return;

    setFieldValue(section, field, summary);
    update(<String>['form']);
  }

  Future<bool> saveNow() async {
    _autosaveTimer?.cancel();
    await _documentCreationFuture;

    final ResumeDocumentModel? document = _document;
    if (document == null) {
      if (saveError.value.isEmpty) {
        saveError.value = 'cvb_draft_create_failed'.tr;
      }
      return false;
    }

    if (isSaving.value) {
      _saveQueued = true;
      while (isSaving.value && !_disposed) {
        await Future<void>.delayed(const Duration(milliseconds: 40));
      }
      if (_disposed) return false;
      return saveNow();
    }

    if (!hasUnsavedChanges.value) return true;

    isSaving.value = true;
    saveError.value = '';
    final int savingRevision = document.revision;
    final int savingChangeSerial = _changeSerial;

    try {
      final ResumeDocumentModel saved = await _apiService.autosaveDocument(
        documentId: document.id,
        expectedRevision: savingRevision,
        title: title,
        data: _snapshotData(),
      );
      _document = saved;
      final bool changedDuringSave = _changeSerial != savingChangeSerial;
      hasUnsavedChanges.value = changedDuringSave;
      if (changedDuringSave) {
        _scheduleAutosave();
      }
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        saveError.value = 'cvb_document_conflict'.tr;
      } else {
        saveError.value = ApiErrorHandler.getErrorMessage(error);
      }
      return false;
    } catch (error) {
      saveError.value = ApiErrorHandler.getErrorMessage(error);
      return false;
    } finally {
      isSaving.value = false;
      if (_saveQueued && !_disposed) {
        _saveQueued = false;
        _scheduleAutosave();
      }
    }
  }

  Future<void> renderCv() async {
    if (isRendering.value) return;

    final CvTemplateModel? template = selectedTemplate.value;
    if (template == null) {
      Get.snackbar(
        'cvb_choose_template'.tr,
        'cvb_select_template_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final List<String> validationErrors = validateRequiredFields();
    if (validationErrors.isNotEmpty) {
      Get.snackbar(
        'cvb_required_fields'.tr,
        validationErrors.take(3).join('\n'),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    isRendering.value = true;
    try {
      final bool saved = await saveNow();
      if (!saved) {
        throw StateError(
          saveError.value.isEmpty
              ? 'cvb_save_before_render_failed'.tr
              : saveError.value,
        );
      }

      final String currentDocumentId = _document?.id ?? '';
      if (currentDocumentId.isEmpty) {
        throw StateError('cvb_draft_not_ready'.tr);
      }

      final ResumeGenerationModel generation = await _apiService.renderDocument(
        documentId: currentDocumentId,
      );

      // Once the first PDF succeeds, this same document can be edited and
      // regenerated without consuming another free slot or paid CV credit.
      creationAccessConsumed.value = true;

      final String controllerTag = 'resume-preview-${generation.id}';
      await Get.to<void>(
        () => CvPreviewView(controllerTag: controllerTag),
        binding: BindingsBuilder(() {
          Get.put<CvPreviewController>(
            CvPreviewController(
              apiService: _apiService,
              generation: generation,
              documentTitle: title,
            ),
            tag: controllerTag,
          );
        }),
        transition: Transition.rightToLeft,
      );
    } on DioException catch (error) {
      final bool noCredit = error.response?.statusCode == 402;
      Get.snackbar(
        noCredit ? 'cvb_no_credit_title'.tr : 'cvb_create_pdf_failed'.tr,
        noCredit
            ? 'cvb_no_credit_message'.tr
            : ApiErrorHandler.getErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } catch (error) {
      Get.snackbar(
        'cvb_create_pdf_failed'.tr,
        ApiErrorHandler.getErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRendering.value = false;
    }
  }

  List<String> validateRequiredFields() {
    final List<String> errors = <String>[];

    for (final CvSectionDefinition section in _schema.visibleSections) {
      if (section.required && _isEmpty(_data[section.key])) {
        errors.add(
          'cvb_section_required'.trParams(<String, String>{
            'section': cvSectionLabel(section),
          }),
        );
        continue;
      }

      if (section.isCollectionSection) {
        final List<Map<String, dynamic>> items = collectionItems(section.key);
        for (int index = 0; index < items.length; index += 1) {
          for (final CvFieldDefinition field in section.visibleFields) {
            if (!isCollectionFieldVisible(section, field, itemIndex: index)) {
              continue;
            }
            if (!field.required) continue;
            if (_isEmpty(items[index][field.leafKey])) {
              errors.add(
                'cvb_collection_field_required'.trParams(<String, String>{
                  'field': cvFieldLabel(field),
                  'section': cvSectionLabel(section),
                  'number': '${index + 1}',
                }),
              );
            }
          }
        }
        continue;
      }

      for (final CvFieldDefinition field in section.visibleFields) {
        if (!field.required) continue;
        if (_isEmpty(fieldValue(section, field))) {
          errors.add(
            'cvb_field_required'.trParams(<String, String>{
              'field': cvFieldLabel(field),
            }),
          );
        }
      }
    }

    return errors;
  }

  void _markDirty() {
    _changeSerial += 1;
    hasUnsavedChanges.value = true;
    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(
      Duration(
        milliseconds: contract.autosaveDebounceMs.clamp(500, 2500).toInt(),
      ),
      () => unawaited(saveNow()),
    );
  }

  Map<String, dynamic> _personalMap() {
    final dynamic raw = _data['personal'];
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      final Map<String, dynamic> converted = Map<String, dynamic>.from(raw);
      _data['personal'] = converted;
      return converted;
    }
    final Map<String, dynamic> created = <String, dynamic>{};
    _data['personal'] = created;
    return created;
  }

  List<Map<String, dynamic>> _mutableCollection(String sectionKey) {
    final dynamic raw = _data[sectionKey];
    if (raw is List<Map<String, dynamic>>) return raw;
    if (raw is List) {
      final List<Map<String, dynamic>> converted = raw
          .whereType<Map>()
          .map((Map item) => Map<String, dynamic>.from(item))
          .toList();
      _data[sectionKey] = converted;
      return converted;
    }
    final List<Map<String, dynamic>> created = <Map<String, dynamic>>[];
    _data[sectionKey] = created;
    return created;
  }

  void _writeValue(Map<String, dynamic> target, String key, dynamic value) {
    if (_isEmpty(value)) {
      target.remove(key);
    } else {
      target[key] = value;
    }
  }

  bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  Map<String, dynamic> _snapshotData() {
    return _deepCopyMap(_data);
  }

  Map<String, dynamic> _deepCopyMap(Map<String, dynamic> source) {
    return source.map<String, dynamic>((String key, dynamic value) {
      if (value is Map) {
        return MapEntry<String, dynamic>(
          key,
          _deepCopyMap(Map<String, dynamic>.from(value)),
        );
      }
      if (value is List) {
        return MapEntry<String, dynamic>(
          key,
          value.map<dynamic>((dynamic item) {
            if (item is Map)
              return _deepCopyMap(Map<String, dynamic>.from(item));
            return item;
          }).toList(),
        );
      }
      return MapEntry<String, dynamic>(key, value);
    });
  }

  @override
  void onClose() {
    _disposed = true;
    _autosaveTimer?.cancel();
    _proactiveAiTimer?.cancel();
    super.onClose();
  }
}
