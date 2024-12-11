# Connect to SharePoint Online with 2FA using Web Login
Connect-PnPOnline -Url https://klaskolaw-admin.sharepoint.com/ -Interactive
# Remove the existing site design
Remove-PnPSiteDesign -Identity '6e936bd6-612f-42c8-815b-1737be1191ef' -Force
#Get-PnPSiteDesign
Get-Pnpsitetemplate -Configuration F:\template.json -out f:\template5.pnp 
#Register-PnPManagementShellAccess
# Add the PnP template to your SharePoint environment
Invoke-PnPTenantTemplate -Path "f:\template5.pnp"
#Get-PnPSiteDesign
# Define the site script JSON content


$siteInfo = "https://klaskolaw-admin.sharepoint.com/sites/DeleteThis"
$siteScriptJson = @"
{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/site-design-script-actions.schema.json",
  "actions": [
    {
      "verb": "createSPList",
      "listName": "[[LDocuments0001_listName]]",
      "templateType": 101,
      "color": "[[LDocuments0001_color]]",
      "icon": "[[LDocuments0001_icon]]",
      "addNavLink": "[[LDocuments0001_addNavLink]]",
      "description": "[[LDocuments0001_description]]",
      "identity": "LDocuments0001",
      "subactions": [
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field ID=\"{08d89a66-4634-42b8-9d5a-0c27395a48b3}\" Type=\"Text\" Name=\"TriggerFlowInfo\" DisplayName=\"Trigger Flow Info\" DisplaceOnUpgrade=\"TRUE\" Hidden=\"TRUE\" ReadOnlyEnforced=\"FALSE\" ReadOnly=\"TRUE\" Required=\"FALSE\" SourceID=\"http://schemas.microsoft.com/sharepoint/v3\" StaticName=\"TriggerFlowInfo\" />"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field ID=\"{321bc046-2178-49bd-893f-7aa4fd61d04e}\" ReadOnly=\"TRUE\" Type=\"Computed\" Name=\"PolicyDisabledUICapabilities\" DisplaceOnUpgrade=\"TRUE\" DisplayName=\"Actions Disabled by Policy\" Filterable=\"FALSE\" Sortable=\"FALSE\" Hidden=\"TRUE\" SourceID=\"http://schemas.microsoft.com/sharepoint/v3\" StaticName=\"PolicyDisabledUICapabilities\"><FieldRefs><FieldRef Name=\"FSObjType\" Key=\"Primary\" /><FieldRef Name=\"ID\" /></FieldRefs><DisplayPattern /></Field>"
        },
        {
          "verb": "addContentType",
          "name": "Folder",
          "id": "0x0120"
        },
        {
          "verb": "addSPView",
          "name": "All Documents",
          "viewFields": [
            "DocIcon",
            "LinkFilename",
            "Modified",
            "Editor"
          ],
          "query": "<OrderBy><FieldRef Name=\"FileLeafRef\" /></OrderBy>",
          "rowLimit": 30,
          "isPaged": true,
          "makeDefault": true,
          "replaceViewFields": true
        }
      ]
    },
    {
      "verb": "createSPList",
      "listName": "[[LEvents0002_listName]]",
      "templateType": 106,
      "color": "[[LEvents0002_color]]",
      "icon": "[[LEvents0002_icon]]",
      "addNavLink": "[[LEvents0002_addNavLink]]",
      "description": "[[LEvents0002_description]]",
      "identity": "LEvents0002",
      "subactions": [
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field ID=\"{8137f7ad-9170-4c1d-a17b-4ca7f557bc88}\" Name=\"ParticipantsPicker\" DisplayName=\"Attendees\" Type=\"UserMulti\" List=\"UserInfo\" Mult=\"TRUE\" Required=\"FALSE\" ShowField=\"ImnName\" UserSelectionMode=\"PeopleAndGroups\" UserSelectionScope=\"0\" Sortable=\"FALSE\" Sealed=\"FALSE\" AllowDeletion=\"FALSE\" SourceID=\"http://schemas.microsoft.com/sharepoint/v3\" StaticName=\"ParticipantsPicker\" />"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field ID=\"{6df9bd52-550e-4a30-bc31-a4366832a87d}\" Name=\"Category\" DisplayName=\"Category\" Type=\"Choice\" Format=\"Dropdown\" FillInChoice=\"TRUE\" SourceID=\"http://schemas.microsoft.com/sharepoint/v3\" StaticName=\"Category\"><CHOICES><CHOICE>Meeting</CHOICE><CHOICE>Work hours</CHOICE><CHOICE>Business</CHOICE><CHOICE>Holiday</CHOICE><CHOICE>Get-together</CHOICE><CHOICE>Gifts</CHOICE><CHOICE>Birthday</CHOICE><CHOICE>Anniversary</CHOICE></CHOICES><Default /></Field>"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field ID=\"{a4e7b3e1-1b0a-4ffa-8426-c94d4cb8cc57}\" Name=\"Facilities\" DisplayName=\"Resources\" Type=\"Facilities\" Mult=\"TRUE\" ShowField=\"Title\" Sortable=\"FALSE\" CanToggleHidden=\"TRUE\" Sealed=\"FALSE\" SourceID=\"http://schemas.microsoft.com/sharepoint/v3\" StaticName=\"Facilities\" />"
        },
        {
          "verb": "addContentType",
          "name": "Event",
          "id": "0x0102"
        },
        {
          "verb": "addSPView",
          "name": "Calendar",
          "viewFields": [
            "EventDate",
            "EndDate",
            "fRecurrence",
            "EventType",
            "WorkspaceLink",
            "Title",
            "Location",
            "Description",
            "Workspace",
            "MasterSeriesItemID",
            "fAllDayEvent"
          ],
          "query": "<Where><DateRangesOverlap><FieldRef Name=\"EventDate\" /><FieldRef Name=\"EndDate\" /><FieldRef Name=\"RecurrenceID\" /><Value Type=\"DateTime\"><Month /></Value></DateRangesOverlap></Where>",
          "rowLimit": 30,
          "isPaged": true,
          "makeDefault": true,
          "replaceViewFields": true,
          "viewDataXml": "<FieldRef Name=\"Title\" Type=\"CalendarMonthTitle\" /><FieldRef Name=\"Title\" Type=\"CalendarWeekTitle\" /><FieldRef Name=\"Location\" Type=\"CalendarWeekLocation\" /><FieldRef Name=\"Title\" Type=\"CalendarDayTitle\" /><FieldRef Name=\"Location\" Type=\"CalendarDayLocation\" />"
        },
        {
          "verb": "addSPView",
          "name": "All Events",
          "viewFields": [
            "fRecurrence",
            "WorkspaceLink",
            "LinkTitle",
            "Location",
            "EventDate",
            "EndDate",
            "fAllDayEvent"
          ],
          "query": "<OrderBy><FieldRef Name=\"EventDate\" /></OrderBy>",
          "rowLimit": 30,
          "isPaged": true,
          "replaceViewFields": true
        },
        {
          "verb": "addSPView",
          "name": "Current Events",
          "viewFields": [
            "fRecurrence",
            "WorkspaceLink",
            "LinkTitle",
            "Location",
            "EventDate",
            "EndDate",
            "fAllDayEvent"
          ],
          "query": "<Where><DateRangesOverlap><FieldRef Name=\"EventDate\" /><FieldRef Name=\"EndDate\" /><FieldRef Name=\"RecurrenceID\" /><Value Type=\"DateTime\"><Now /></Value></DateRangesOverlap></Where><OrderBy><FieldRef Name=\"EventDate\" /></OrderBy>",
          "rowLimit": 30,
          "isPaged": true,
          "replaceViewFields": true
        }
      ]
    },
    {
      "verb": "createSPList",
      "listName": "[[LNew_hire_checklist0003_listName]]",
      "templateType": 100,
      "color": "[[LNew_hire_checklist0003_color]]",
      "icon": "[[LNew_hire_checklist0003_icon]]",
      "addNavLink": "[[LNew_hire_checklist0003_addNavLink]]",
      "description": "[[LNew_hire_checklist0003_description]]",
      "identity": "LNew_hire_checklist0003",
      "subactions": [
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field ID=\"{fa564e0f-0c70-4ab9-b863-0177e6ddd247}\" Type=\"Text\" Name=\"Title\" DisplayName=\"Title\" Required=\"TRUE\" SourceID=\"http://schemas.microsoft.com/sharepoint/v3\" StaticName=\"Title\" FromBaseType=\"TRUE\" ShowInNewForm=\"TRUE\" ShowInEditForm=\"TRUE\" />"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field DisplayName=\"Task name\" Format=\"Dropdown\" MaxLength=\"255\" Name=\"Task_x0020_name\" Title=\"Task name\" Type=\"Text\" ID=\"{10c7b608-1a05-4e33-8b6d-edcf72b3c28f}\" StaticName=\"Task_x0020_name\" />"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field Name=\"_x0077_wl7\" DisplayName=\"Complete by\" Type=\"Text\" ID=\"{83966e32-9a52-4016-9edd-6cf6e4ba550d}\" StaticName=\"_x0077_wl7\" />"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field Name=\"rgwr\" DisplayName=\"Notes\" Type=\"Text\" ID=\"{17f40689-f3e6-4df1-9f88-8e800a0c0d14}\" StaticName=\"rgwr\" />"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field Name=\"ehxz\" DisplayName=\"Resource\" Type=\"Text\" ID=\"{8f1d7d01-1e20-492d-8fd6-bb084810d674}\" StaticName=\"ehxz\" />"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field Type=\"URL\" DisplayName=\"Link\" Required=\"FALSE\" EnforceUniqueValues=\"FALSE\" Indexed=\"FALSE\" Format=\"Hyperlink\" ID=\"{6492b4fb-eb53-4b92-9e39-f6e1e238ec42}\" StaticName=\"Link\" Name=\"Link\" />"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field DisplayName=\"Task image\" Format=\"Image\" Name=\"Task_x0020_image\" Title=\"Task image\" Type=\"URL\" ID=\"{2bd53acf-7418-4b1a-9417-6c3bc079b7e8}\" StaticName=\"Task_x0020_image\" />"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field Name=\"s8hr\" DisplayName=\"Text\" Type=\"Text\" ID=\"{262db922-c825-4653-baf8-c02b235f5554}\" StaticName=\"s8hr\" />"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field ID=\"{c042a256-787d-4a6f-8a8a-cf6ab767f12d}\" Type=\"Computed\" DisplayName=\"Content Type\" Name=\"ContentType\" DisplaceOnUpgrade=\"TRUE\" RenderXMLUsingPattern=\"TRUE\" Sortable=\"FALSE\" SourceID=\"http://schemas.microsoft.com/sharepoint/v3\" StaticName=\"ContentType\" Group=\"_Hidden\" PITarget=\"MicrosoftWindowsSharePointServices\" PIAttribute=\"ContentTypeID\" FromBaseType=\"TRUE\"><FieldRefs><FieldRef Name=\"ContentTypeId\" /></FieldRefs><DisplayPattern><MapToContentType><Column Name=\"ContentTypeId\" /></MapToContentType></DisplayPattern></Field>"
        },
        {
          "verb": "addContentType",
          "name": "Item",
          "id": "0x01",
          "fieldRefsXml": [
            "<FieldRef ID=\"{c042a256-787d-4a6f-8a8a-cf6ab767f12d}\" Name=\"ContentType\" />",
            "<FieldRef ID=\"{fa564e0f-0c70-4ab9-b863-0177e6ddd247}\" Name=\"Title\" Required=\"TRUE\" ShowInNewForm=\"TRUE\" ShowInEditForm=\"TRUE\" />",
            "<FieldRef ID=\"{10c7b608-1a05-4e33-8b6d-edcf72b3c28f}\" Name=\"Task_x0020_name\" DisplayName=\"Task name\" Format=\"Dropdown\" />",
            "<FieldRef ID=\"{83966e32-9a52-4016-9edd-6cf6e4ba550d}\" Name=\"_x0077_wl7\" DisplayName=\"Complete by\" />",
            "<FieldRef ID=\"{17f40689-f3e6-4df1-9f88-8e800a0c0d14}\" Name=\"rgwr\" DisplayName=\"Notes\" />",
            "<FieldRef ID=\"{8f1d7d01-1e20-492d-8fd6-bb084810d674}\" Name=\"ehxz\" DisplayName=\"Resource\" />",
            "<FieldRef ID=\"{6492b4fb-eb53-4b92-9e39-f6e1e238ec42}\" Name=\"Link\" DisplayName=\"Link\" Required=\"FALSE\" Format=\"Hyperlink\" />",
            "<FieldRef ID=\"{2bd53acf-7418-4b1a-9417-6c3bc079b7e8}\" Name=\"Task_x0020_image\" DisplayName=\"Task image\" Format=\"Image\" />",
            "<FieldRef ID=\"{262db922-c825-4653-baf8-c02b235f5554}\" Name=\"s8hr\" DisplayName=\"Text\" />"
          ]
        },
        {
          "verb": "addContentType",
          "name": "Folder",
          "id": "0x0120"
        },
        {
          "verb": "addSPView",
          "name": "All Items",
          "viewFields": [
            "LinkTitle",
            "Task_x0020_name",
            "_x0077_wl7",
            "rgwr",
            "ehxz",
            "Link",
            "s8hr"
          ],
          "query": "",
          "rowLimit": 30,
          "isPaged": true,
          "makeDefault": true,
          "formatterJSON": "{\"additionalRowClass\":{\"operator\":\":\",\"operands\":[{\"operator\":\"==\",\"operands\":[{\"operator\":\"%\",\"operands\":[\"@rowIndex\",2]},0]},\"sp-css-backgroundColor-neutralBackground\",{\"operator\":\":\",\"operands\":[{\"operator\":\"==\",\"operands\":[{\"operator\":\"%\",\"operands\":[\"@rowIndex\",2]},1]},\"sp-css-backgroundColor-noFill\",\"\"]}]},\"rowClassTemplateId\":\"BgColorAlternateRows\"}",
          "replaceViewFields": true
        }
      ]
    },
    {
      "verb": "createSPList",
      "listName": "[[LNewHireQuestionnaire0004_listName]]",
      "templateType": 100,
      "color": "[[LNewHireQuestionnaire0004_color]]",
      "icon": "[[LNewHireQuestionnaire0004_icon]]",
      "addNavLink": "[[LNewHireQuestionnaire0004_addNavLink]]",
      "description": "[[LNewHireQuestionnaire0004_description]]",
      "identity": "LNewHireQuestionnaire0004",
      "subactions": [
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field ID=\"{fa564e0f-0c70-4ab9-b863-0177e6ddd247}\" Type=\"Text\" Name=\"Title\" DisplayName=\"Title\" Required=\"TRUE\" SourceID=\"http://schemas.microsoft.com/sharepoint/v3\" StaticName=\"Title\" FromBaseType=\"TRUE\" ShowInNewForm=\"TRUE\" ShowInEditForm=\"TRUE\" />"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field AppendOnly=\"FALSE\" DisplayName=\"Question\" Format=\"Dropdown\" IsolateStyles=\"FALSE\" Name=\"Question\" RichText=\"FALSE\" RichTextMode=\"Compatible\" Title=\"Question\" Type=\"Note\" ID=\"{3807967f-ec17-4a2d-8c79-a833112972fc}\" StaticName=\"Question\" />"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field DisplayName=\"Active\" Format=\"Dropdown\" Name=\"Active\" Title=\"Active\" Type=\"Boolean\" ID=\"{f93308ee-7cc3-4a02-bb1d-ca1de1391a28}\" StaticName=\"Active\"><Default>1</Default></Field>"
        },
        {
          "verb": "addSPFieldXml",
          "schemaXml": "<Field ID=\"{c042a256-787d-4a6f-8a8a-cf6ab767f12d}\" Type=\"Computed\" DisplayName=\"Content Type\" Name=\"ContentType\" DisplaceOnUpgrade=\"TRUE\" RenderXMLUsingPattern=\"TRUE\" Sortable=\"FALSE\" SourceID=\"http://schemas.microsoft.com/sharepoint/v3\" StaticName=\"ContentType\" Group=\"_Hidden\" PITarget=\"MicrosoftWindowsSharePointServices\" PIAttribute=\"ContentTypeID\" FromBaseType=\"TRUE\"><FieldRefs><FieldRef Name=\"ContentTypeId\" /></FieldRefs><DisplayPattern><MapToContentType><Column Name=\"ContentTypeId\" /></MapToContentType></DisplayPattern></Field>"
        },
        {
          "verb": "addContentType",
          "name": "Item",
          "id": "0x01",
          "fieldRefsXml": [
            "<FieldRef ID=\"{c042a256-787d-4a6f-8a8a-cf6ab767f12d}\" Name=\"ContentType\" />",
            "<FieldRef ID=\"{fa564e0f-0c70-4ab9-b863-0177e6ddd247}\" Name=\"Title\" Required=\"TRUE\" ShowInNewForm=\"TRUE\" ShowInEditForm=\"TRUE\" />",
            "<FieldRef ID=\"{3807967f-ec17-4a2d-8c79-a833112972fc}\" Name=\"Question\" />",
            "<FieldRef ID=\"{f93308ee-7cc3-4a02-bb1d-ca1de1391a28}\" Name=\"Active\" />"
          ]
        },
        {
          "verb": "addContentType",
          "name": "Folder",
          "id": "0x0120"
        },
        {
          "verb": "addSPView",
          "name": "All Items",
          "viewFields": [
            "Question",
            "Active"
          ],
          "query": "",
          "rowLimit": 30,
          "isPaged": true,
          "makeDefault": true,
          "formatterJSON": "",
          "replaceViewFields": true
        }
      ]
    },
    {
      "verb": "setSiteBranding",
      "navigationLayout": "Megamenu",
      "headerLayout": "Compact",
      "headerBackground": "Strong",
      "showFooter": true
    },
    {
      "verb": "applyTheme",
      "themeJson": {
        "version": "2",
        "isInverted": false,
        "palette": {
          "neutralPrimaryAlt": "#ff2f2f2f",
          "themeLighterAlt": "#fff4f5f8",
          "black": "#ff000000",
          "themeTertiary": "#ff727c97",
          "primaryBackground": "#ffffffff",
          "neutralQuaternaryAlt": "#ffe1dfdd",
          "accent": "#ff17717a",
          "themePrimary": "#ff303952",
          "neutralSecondary": "#ff373737",
          "themeLighter": "#ffd4d8e3",
          "themeDark": "#ff252b3e",
          "neutralPrimary": "#ff000000",
          "neutralLighterAlt": "#fffaf9f8",
          "neutralLighter": "#fff3f2f1",
          "neutralDark": "#ff151515",
          "neutralQuaternary": "#ffd0d0d0",
          "neutralLight": "#ffedebe9",
          "primaryText": "#ff000000",
          "themeDarker": "#ff1b202e",
          "neutralTertiaryAlt": "#ffc8c6c4",
          "themeDarkAlt": "#ff2b3349",
          "white": "#ffffffff",
          "bodyBackground": "#ffffffff",
          "themeSecondary": "#ff414b66",
          "bodyText": "#ff000000",
          "disabledBackground": "#fff4f4f4",
          "neutralTertiary": "#ff595959",
          "themeLight": "#ffb2b9cb",
          "disabledText": "#ffc8c8c8",
          "HyperlinkActive": "#ff1b202e",
          "CommandLinksPressed": "#ff1b202e",
          "NavigationPressed": "#ff1b202e",
          "EmphasisHoverBorder": "#ff1b202e",
          "TopBarPressedText": "#ff1b202e",
          "HeaderNavigationPressedText": "#ff1b202e",
          "Hyperlinkfollowed": "#ff1b202e",
          "EmphasisHoverBackground": "#ff252b3e",
          "EmphasisBorder": "#ff252b3e",
          "AccentText": "#ff303952",
          "CommandLinksHover": "#ff303952",
          "RowAccent": "#ff303952",
          "NavigationAccent": "#ff303952",
          "NavigationHover": "#ff303952",
          "EmphasisBackground": "#ff303952",
          "HeaderNavigationHoverText": "#ff303952",
          "HeaderNavigationSelectedText": "#ff303952",
          "SuiteBarBackground": "#ff303952",
          "Hyperlink": "#ff303952",
          "ContentAccent1": "#ff303952",
          "AccentLines": "#ff414b66",
          "HeaderAccentLines": "#ff414b66",
          "ButtonPressedBorder": "#ff414b66",
          "SuiteBarHoverBackground": "#ff727c97",
          "StrongLines": "#ffb2b9cb",
          "HeaderStrongLines": "#ffb2b9cb",
          "SuiteBarHoverText": "#ffb2b9cb",
          "ButtonPressedBackground": "#ffb2b9cb",
          "ButtonHoverBorder": "#ffb2b9cb",
          "ButtonHoverBackground": "#ffd4d8e3",
          "SelectionBackground": "#7fb2b9cb",
          "HoverBackground": "#7fd4d8e3",
          "NavigationHoverBackground": "#7fd4d8e3",
          "PageBackground": "#ffffffff",
          "EmphasisText": "#ffffffff",
          "SuiteBarText": "#ffffffff",
          "TileText": "#ffffffff",
          "BackgroundOverlay": "#d8ffffff",
          "HeaderBackground": "#d8ffffff",
          "FooterBackground": "#d8ffffff",
          "DisabledBackground": "#fffaf9f8",
          "HeaderDisabledBackground": "#fffaf9f8",
          "ButtonBackground": "#fffaf9f8",
          "ButtonDisabledBackground": "#fffaf9f8",
          "SubtleEmphasisBackground": "#fff3f2f1",
          "DialogBorder": "#fff3f2f1",
          "NavigationSelectedBackground": "#c6edebe9",
          "TopBarBackground": "#c6edebe9",
          "DisabledLines": "#ffedebe9",
          "HeaderDisabledLines": "#ffedebe9",
          "ButtonDisabledBorder": "#ffedebe9",
          "SuiteBarDisabledText": "#ffedebe9",
          "SubtleLines": "#ffc8c6c4",
          "HeaderSubtleLines": "#ffc8c6c4",
          "ButtonGlyphDisabled": "#ffc8c6c4",
          "DisabledText": "#ff595959",
          "CommandLinksDisabled": "#ff595959",
          "HeaderDisableText": "#ff595959",
          "ButtonDisabledText": "#ff595959",
          "Lines": "#ff595959",
          "HeaderLines": "#ff595959",
          "ButtonBorder": "#ff595959",
          "CommandLinks": "#ff373737",
          "Navigation": "#ff373737",
          "SubtleEmphasisText": "#ff373737",
          "TopBarText": "#ff373737",
          "HeaderNavigationText": "#ff373737",
          "ButtonGlyph": "#ff373737",
          "BodyText": "#ff000000",
          "WebPartHeading": "#ff000000",
          "HeaderText": "#ff000000",
          "ButtonText": "#ff000000",
          "ButtonGlyphActive": "#ff000000",
          "TopBarHoverText": "#ff000000",
          "StrongBodyText": "#ff151515",
          "SiteTitle": "#ff151515",
          "CommandLinksSecondary": "#ff151515",
          "SubtleEmphasisCommandLinks": "#ff151515",
          "HeaderSiteTitle": "#ff151515",
          "TileBackgroundOverlay": "#7f000000",
          "ContentAccent2": "#ff00485b",
          "ContentAccent3": "#ff288054",
          "ContentAccent4": "#ff767956",
          "ContentAccent5": "#ffed0033",
          "ContentAccent6": "#ff682a7a"
        }
      }
    },
    {
      "verb": "setSiteExternalSharingCapability",
      "capability": "Disabled"
    },
    {
      "verb": "setRegionalSettings",
      "timeZone": 10,
      "locale": 1033,
      "sortOrder": 25,
      "hourFormat": "12"
    }
  ],
  "bindings": {
    "LDocuments0001_listName": {
      "source": "Input",
      "defaultValue": "Documents"
    },
    "LDocuments0001_icon": {
      "source": "Input",
      "defaultValue": "0"
    },
    "LDocuments0001_description": {
      "source": "Input",
      "defaultValue": ""
    },
    "LDocuments0001_color": {
      "source": "Input",
      "defaultValue": "0"
    },
    "LDocuments0001_addNavLink": {
      "source": "Input",
      "defaultValue": "false"
    },
    "LEvents0002_listName": {
      "source": "Input",
      "defaultValue": "Events"
    },
    "LEvents0002_icon": {
      "source": "Input",
      "defaultValue": "0"
    },
    "LEvents0002_description": {
      "source": "Input",
      "defaultValue": ""
    },
    "LEvents0002_color": {
      "source": "Input",
      "defaultValue": "0"
    },
    "LEvents0002_addNavLink": {
      "source": "Input",
      "defaultValue": "false"
    },
    "LNew_hire_checklist0003_listName": {
      "source": "Input",
      "defaultValue": "New hire checklist"
    },
    "LNew_hire_checklist0003_icon": {
      "source": "Input",
      "defaultValue": "0"
    },
    "LNew_hire_checklist0003_description": {
      "source": "Input",
      "defaultValue": "Corporate new hire checklist"
    },
    "LNew_hire_checklist0003_color": {
      "source": "Input",
      "defaultValue": "0"
    },
    "LNew_hire_checklist0003_addNavLink": {
      "source": "Input",
      "defaultValue": "false"
    },
    "LNewHireQuestionnaire0004_listName": {
      "source": "Input",
      "defaultValue": "NewHireQuestionnaire"
    },
    "LNewHireQuestionnaire0004_icon": {
      "source": "Input",
      "defaultValue": "0"
    },
    "LNewHireQuestionnaire0004_description": {
      "source": "Input",
      "defaultValue": ""
    },
    "LNewHireQuestionnaire0004_color": {
      "source": "Input",
      "defaultValue": "0"
    },
    "LNewHireQuestionnaire0004_addNavLink": {
      "source": "Input",
      "defaultValue": "false"
    }
  }
}
}
"@
 
# Add the site script
$siteScript = Add-PnPSiteScript -Title "Klasko Site Template 2" -Content 
 
# Retrieve the ID of the added site script
$siteScriptId = $siteScript.Id
 
# Output the ID of the added site script
Write-Host "Site Script ID: $siteScriptId"
 
# Add the site design and associate it with the added site script
Add-PnPSiteDesign -Title "Klasko Site Template 2" -WebTemplate "64" -SiteScriptIds $siteScriptId -Description "Custom site design for Klaskolaw" 

Connect-PnPOnline -Url https://klaskolaw-admin.sharepoint.com/ -Interactive
Invoke-PnPTenantTemplate -Path F:\templatenew.pnp -Parameters @{"SiteUrl"="/sites/deletethis3"} 
Invoke-PnPSiteTemplate -Path F:\templatenew.pnp -Parameters @{"SiteUrl"="/sites/deletethis3"} 