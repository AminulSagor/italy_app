from pathlib import Path

from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_ALIGN_VERTICAL, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor


OUTPUT = Path(__file__).with_name("Italir_Pothe_Backend_Advertising_Control_Guide.docx")

NAVY = "17365D"
PALE_BLUE = "EAF2F8"
PALE_GRAY = "F5F7F9"
MID_GRAY = "D9D9D9"
TEXT = RGBColor(31, 41, 55)


def set_cell_fill(cell, color):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), color)


def set_cell_margins(cell, top=110, start=120, bottom=110, end=120):
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
    tc_mar = tc_pr.first_child_found_in("w:tcMar")
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc_pr.append(tc_mar)
    for margin, value in (("top", top), ("start", start), ("bottom", bottom), ("end", end)):
        node = tc_mar.find(qn(f"w:{margin}"))
        if node is None:
            node = OxmlElement(f"w:{margin}")
            tc_mar.append(node)
        node.set(qn("w:w"), str(value))
        node.set(qn("w:type"), "dxa")


def set_table_borders(table, color=MID_GRAY, size="6"):
    tbl_pr = table._tbl.tblPr
    borders = tbl_pr.find(qn("w:tblBorders"))
    if borders is None:
        borders = OxmlElement("w:tblBorders")
        tbl_pr.append(borders)
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        tag = borders.find(qn(f"w:{edge}"))
        if tag is None:
            tag = OxmlElement(f"w:{edge}")
            borders.append(tag)
        tag.set(qn("w:val"), "single")
        tag.set(qn("w:sz"), size)
        tag.set(qn("w:space"), "0")
        tag.set(qn("w:color"), color)


def set_repeat_table_header(row):
    tr_pr = row._tr.get_or_add_trPr()
    tbl_header = OxmlElement("w:tblHeader")
    tbl_header.set(qn("w:val"), "true")
    tr_pr.append(tbl_header)


def keep_with_next(paragraph):
    paragraph.paragraph_format.keep_with_next = True


def add_heading(doc, text, level=1):
    p = doc.add_paragraph(text, style=f"Heading {level}")
    keep_with_next(p)
    return p


def add_bullet(doc, text, level=0):
    style = "List Bullet" if level == 0 else "List Bullet 2"
    p = doc.add_paragraph(style=style)
    p.add_run(text)
    return p


def add_number(doc, text):
    p = doc.add_paragraph(style="List Number")
    p.add_run(text)
    return p


def add_table(doc, headers, rows, widths, font_size=9.2):
    table = doc.add_table(rows=1, cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    set_table_borders(table)
    header = table.rows[0]
    set_repeat_table_header(header)
    for idx, (cell, label, width) in enumerate(zip(header.cells, headers, widths)):
        cell.width = Inches(width)
        cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
        set_cell_fill(cell, NAVY)
        set_cell_margins(cell, top=125, bottom=125)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(0)
        run = p.add_run(label)
        run.bold = True
        run.font.color.rgb = RGBColor(255, 255, 255)
        run.font.size = Pt(font_size)
    for row_idx, values in enumerate(rows):
        row = table.add_row()
        shade = "FFFFFF" if row_idx % 2 == 0 else PALE_BLUE
        for idx, (cell, value, width) in enumerate(zip(row.cells, values, widths)):
            cell.width = Inches(width)
            cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            set_cell_fill(cell, shade)
            set_cell_margins(cell)
            p = cell.paragraphs[0]
            p.paragraph_format.space_after = Pt(0)
            p.paragraph_format.line_spacing = 1.05
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER if idx == len(values) - 1 and len(value) < 12 else WD_ALIGN_PARAGRAPH.LEFT
            run = p.add_run(value)
            run.font.size = Pt(font_size)
    after = doc.add_paragraph()
    after.paragraph_format.space_after = Pt(0)
    return table


def add_key_value(doc, label, value):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(5)
    r = p.add_run(label + " ")
    r.bold = True
    p.add_run(value)


doc = Document()
doc.settings.odd_and_even_pages_header_footer = False
section = doc.sections[0]
section.page_width = Inches(8.5)
section.page_height = Inches(11)
section.top_margin = Inches(0.68)
section.bottom_margin = Inches(0.68)
section.left_margin = Inches(0.72)
section.right_margin = Inches(0.72)

styles = doc.styles
normal = styles["Normal"]
normal.font.name = "Aptos"
normal.font.size = Pt(10.5)
normal.font.color.rgb = TEXT
normal.paragraph_format.space_after = Pt(7)
normal.paragraph_format.line_spacing = 1.08

title_style = styles["Title"]
title_style.font.name = "Aptos Display"
title_style.font.size = Pt(27)
title_style.font.bold = True
title_style.font.color.rgb = RGBColor(0, 0, 0)
title_style.paragraph_format.space_after = Pt(14)
title_ppr = title_style.element.get_or_add_pPr()
title_border = title_ppr.find(qn("w:pBdr"))
if title_border is not None:
    title_ppr.remove(title_border)

for name, size, before, after in (("Heading 1", 17, 17, 7), ("Heading 2", 12.5, 12, 5)):
    style = styles[name]
    style.font.name = "Aptos Display"
    style.font.size = Pt(size)
    style.font.bold = True
    style.font.color.rgb = RGBColor(0, 0, 0)
    style.paragraph_format.space_before = Pt(before)
    style.paragraph_format.space_after = Pt(after)

for list_name in ("List Bullet", "List Bullet 2", "List Number"):
    styles[list_name].font.name = "Aptos"
    styles[list_name].font.size = Pt(10.5)
    styles[list_name].paragraph_format.space_after = Pt(4)

footer = section.footer
fp = footer.paragraphs[0]
fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
fp.paragraph_format.space_before = Pt(4)
fr = fp.add_run("Italir Pothe  |  Backend Advertising Control Guide  |  9 November 2026")
fr.font.name = "Aptos"
fr.font.size = Pt(8)
fr.font.color.rgb = RGBColor(100, 116, 139)

# Cover and executive summary
p = doc.add_paragraph(style="Title")
p.add_run("Italir Pothe Backend Advertising Control Guide")
p_border = p._p.get_or_add_pPr().find(qn("w:pBdr"))
if p_border is not None:
    p._p.get_or_add_pPr().remove(p_border)

p = doc.add_paragraph()
p.paragraph_format.space_after = Pt(18)
r = p.add_run("Client operating guide for native ads rewarded ads and ad free subscriptions")
r.font.name = "Aptos Display"
r.font.size = Pt(14)
r.font.color.rgb = RGBColor(71, 85, 105)

doc.add_paragraph(
    "This guide explains which advertising features can be controlled from the backend, what the current production settings mean, and how to make changes safely. The controls are active in production and are read by the mobile app through the backend configuration response."
)

add_heading(doc, "Current production position", 1)
add_bullet(doc, "The backend is online with 48 explicit native and rewarded advertising controls deployed.")
add_bullet(doc, "Global advertising and native advertising are enabled.")
add_bullet(doc, "The native ad at free video completion is enabled. The older native ad at 60 percent video progress is disabled.")
add_bullet(doc, "Rewarded call limiting is disabled, so the existing Play Store app keeps its legacy unlimited calling behavior.")
add_bullet(doc, "Production database safety settings remain unchanged: schema synchronization and automatic migrations stay disabled.")

add_heading(doc, "How the controls work", 1)
doc.add_paragraph(
    "Boolean controls use true or false. A first after value decides how many items appear before the first native ad. An interval value decides how frequently the ad repeats after that point. Environment changes in Railway normally redeploy the backend before they take effect."
)
add_key_value(doc, "Ad free users", "Users with an active ad free subscription are excluded from rewarded session requirements and ad display decisions returned by the backend.")
add_key_value(doc, "App controlled presentation", "The backend decides availability, intervals, limits, and rewards. Visual size, padding, consent dialog design, and the exact position inside a screen remain mobile app responsibilities.")

doc.add_page_break()

# Admin panel and globals
add_heading(doc, "Controls available in the admin panel", 1)
doc.add_paragraph(
    "Ad free packages are managed in Admin, then Package Store, then Ad Free. The administrator can create monthly and yearly packages and enable or disable them without changing advertising environment variables."
)
add_table(
    doc,
    ["Field", "Purpose", "Client guidance"],
    [
        ("Plan type", "Monthly or yearly subscription duration.", "Create one package for each required duration."),
        ("Apple product ID", "Matches the subscription product configured in App Store Connect.", "Enter the exact store identifier."),
        ("Google product ID", "Matches the Google Play subscription product.", "The monthly and yearly plans may share one product ID."),
        ("Google base plan ID", "Identifies the monthly or yearly Google Play base plan.", "Use the exact matching base plan ID for each package."),
        ("Published status", "Controls whether the package is available to the app.", "Enable only after the store product is active and verified."),
    ],
    [1.35, 2.65, 2.95],
)

add_heading(doc, "Global backend switches", 1)
add_table(
    doc,
    ["Environment variable", "Current value", "Effect"],
    [
        ("ADS_ENABLED", "true", "Master switch for rewarded advertising configuration and session creation."),
        ("NATIVE_ADS_ENABLED", "true", "Master switch for all native ad placements returned by the backend."),
        ("REWARDED_CALL_LIMIT_ENABLED", "false", "Keeps legacy calling unlimited. Do not enable until the compatible mobile build is live."),
        ("NODE_ENV", "production", "Keeps production security behavior active, including blocking the test completion endpoint."),
        ("TYPEORM_SYNC", "false", "Prevents automatic schema synchronization in production."),
        ("TYPEORM_RUN_MIGRATIONS", "false", "Prevents pending migrations from running automatically at application startup."),
    ],
    [2.25, 1.0, 3.7],
)

doc.add_paragraph(
    "Important: never change NODE_ENV to development in production. The development-only rewarded completion route does not prove that an ad was watched and must remain unavailable to production users."
)

doc.add_page_break()

# Native placements
add_heading(doc, "Native advertising controls", 1)
doc.add_paragraph(
    "All listed native placements are enabled unless noted otherwise. Values in the behavior column reflect the current production configuration."
)
native_rows = [
    ("Home", "NATIVE_HOME_ENABLED", "Enabled"),
    ("Practice Hub", "NATIVE_PRACTICE_HUB_ENABLED", "Enabled"),
    ("AI Tutor landing", "NATIVE_AI_TUTOR_LANDING_ENABLED", "Enabled"),
    ("Course catalog", "NATIVE_COURSE_CATALOG_ENABLED", "After 3 items"),
    ("Course detail", "NATIVE_COURSE_DETAIL_ENABLED", "After 3 items"),
    ("Career tracks", "NATIVE_CAREER_TRACKS_ENABLED", "After 2 items"),
    ("Career track detail", "NATIVE_CAREER_TRACK_DETAIL_ENABLED", "Enabled"),
    ("Career sentences", "NATIVE_CAREER_SENTENCES_ENABLED", "After 3 then every 4"),
    ("Survival Italian", "NATIVE_SURVIVAL_ENABLED", "After 4 items"),
    ("Important verbs", "NATIVE_VERBS_ENABLED", "After 1 then every 4"),
    ("Saved verbs", "NATIVE_SAVED_VERBS_ENABLED", "After 1 then every 4"),
    ("Verb detail", "NATIVE_VERB_DETAIL_ENABLED", "Every 3 eligible views"),
    ("League", "NATIVE_LEAGUE_ENABLED", "After 3 then every 4"),
    ("Messages", "NATIVE_MESSAGES_ENABLED", "After 3 then every 4"),
    ("Vocabulary", "NATIVE_VOCABULARY_ENABLED", "After 3 then every 4"),
    ("Free video at progress", "NATIVE_FREE_VIDEO_PROGRESS_ENABLED", "Disabled"),
    ("Free video completed", "NATIVE_FREE_VIDEO_COMPLETE_ENABLED", "Enabled at completion"),
]
add_table(doc, ["Placement", "Main switch", "Current behavior"], native_rows, [1.65, 3.25, 2.05], font_size=8.7)

add_heading(doc, "Native interval variables", 2)
doc.add_paragraph(
    "Placements that repeat use matching FIRST_AFTER and INTERVAL variables. Current values are shown above. The free video progress threshold remains configured as NATIVE_VIDEO_PROGRESS_PERCENT=60, but its native placement switch is false, so no native ad is shown at that threshold."
)

doc.add_page_break()

# Rewarded controls
add_heading(doc, "Rewarded advertising controls", 1)
doc.add_paragraph(
    "Rewarded ads use a verified session. In production, Google AdMob server side verification confirms completion before the backend grants a reward. The development test completion route is intentionally blocked in production."
)
add_table(
    doc,
    ["User action", "Environment variable", "Current rule"],
    [
        ("Career module", "REWARDED_CAREER_INTERVAL", "Every 3 eligible opens"),
        ("Quiz opening", "REWARDED_QUIZ_INTERVAL", "Every 3 eligible opens"),
        ("Vocabulary reveal", "REWARDED_VOCABULARY_REVEAL_INTERVAL", "Every 6 eligible reveals"),
        ("Survival PDF", "REWARDED_SURVIVAL_PDF_INTERVAL", "Every 3 eligible opens"),
        ("Important verb detail", "REWARDED_VERB_INTERVAL", "Every 3 eligible opens"),
        ("Free video", "ADS_ENABLED", "Rewarded gate is triggered by the mobile app at 60 percent; no separate backend interval."),
        ("Daily challenge", "REWARDED_DAILY_CHALLENGE_MAX", "Maximum 3 rewarded bonuses per day"),
        ("Daily challenge reward", "REWARDED_DAILY_CHALLENGE_XP", "10 XP per verified ad"),
        ("Daily chest", "REWARDED_DAILY_CHEST_REQUIRED", "Rewarded ad required"),
        ("CV credit", "REWARDED_CV_CREDITS_PER_AD", "1 credit per verified ad"),
        ("Outgoing calls", "REWARDED_CALL_LIMIT_ENABLED", "Disabled; legacy behavior remains active"),
        ("Initial free calls", "REWARDED_INITIAL_FREE_CALLS", "1 if call limiting is enabled later"),
        ("Call reward", "REWARDED_CALL_CREDITS_PER_AD", "3 call credits per verified ad"),
    ],
    [1.55, 3.05, 2.35],
    font_size=8.8,
)

add_heading(doc, "Rewarded completion and security", 2)
add_bullet(doc, "Production rewards must be granted only after a valid AdMob server side verification callback.")
add_bullet(doc, "The user must own the pending rewarded session, and duplicate completion is prevented.")
add_bullet(doc, "Debug test ads may display against production, but the debug completion endpoint cannot grant a reward while NODE_ENV is production.")
add_bullet(doc, "For full production testing, use an internal release build with the production rewarded ad unit and server side verification configured.")

doc.add_page_break()

# Operations
add_heading(doc, "Safe operating procedure", 1)
doc.add_paragraph(
    "Use this sequence whenever a backend advertising control is changed. It limits risk to existing Play Store users and makes rollback straightforward."
)
for step in [
    "Confirm the intended user experience and identify the single variable or small group of variables that controls it.",
    "Record the current values before editing Railway.",
    "Change values in the production backend service only. Do not edit database safety settings as part of an advertising change.",
    "Review Railway's staged change summary, then deploy the variables.",
    "Wait until the new deployment is Active and the backend service is Online.",
    "Test with a non ad free account and verify both the expected ad placement and the no ad behavior for ad free users.",
    "If behavior is incorrect, restore the recorded values and redeploy.",
]:
    add_number(doc, step)

add_heading(doc, "Changes that require extra care", 1)
add_table(
    doc,
    ["Change", "Risk", "Required decision"],
    [
        ("Enable call limiting", "Existing users could suddenly be blocked after the free allowance.", "Wait for the compatible Play Store build, then enable REWARDED_CALL_LIMIT_ENABLED."),
        ("Change NODE_ENV", "Could expose development-only behavior and weaken rewarded verification.", "Never use development or test mode in production."),
        ("Enable TypeORM sync or auto migrations", "Could alter the production schema during application startup.", "Keep both settings false and use a controlled migration release."),
        ("Reduce intervals sharply", "Increases ad frequency and may harm user experience.", "Test with representative content before production rollout."),
        ("Publish an ad free plan", "Store identifiers must match or purchases and restore may fail.", "Verify Apple product ID, Google product ID, and Google base plan ID first."),
    ],
    [1.65, 2.55, 2.75],
    font_size=9.0,
)

add_heading(doc, "Quick client reference", 1)
add_bullet(doc, "Turn all ads off: set ADS_ENABLED=false and NATIVE_ADS_ENABLED=false, then redeploy.")
add_bullet(doc, "Turn native ads off only: set NATIVE_ADS_ENABLED=false, then redeploy.")
add_bullet(doc, "Disable one native placement: set its NATIVE ... ENABLED variable to false.")
add_bullet(doc, "Change rewarded frequency: adjust only the matching REWARDED ... INTERVAL value.")
add_bullet(doc, "Keep existing Play Store calling unaffected: leave REWARDED_CALL_LIMIT_ENABLED=false.")
add_bullet(doc, "Manage monthly and yearly ad free subscriptions: use Admin, Package Store, Ad Free.")

doc.add_paragraph()
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run("End of guide")
r.bold = True
r.font.size = Pt(9)
r.font.color.rgb = RGBColor(100, 116, 139)

doc.save(OUTPUT)
print(OUTPUT)
