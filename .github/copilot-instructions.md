# Architecture rules

- Scan the codebase before making changes.
- Follow standard CVM architecture using Core, Modules, and Routes+ the main folder.
- Models are the source of truth.
- Services receive payload models and return UI models from API JSON using toJson/fromJson.
- Controllers expose reactive models to the UI and update fields using copyWith.
- Controllers call services through the API error handler.
- API error handler returns a fixed response model object (defined within the same file) with data<T>, success flag, and errorCode, and handles user-facing errors consistently. 
- Each module should have dedicated model, service, controller, and view files/folders.
- Shared logic across modules should go into a shared module/submodule.
- Cross-cutting services/models/controllers go in Core.


## Base App Initialization (Exact Scaffold)

- When initializing the base app, keep this exact root structure:
	- `analysis_options.yaml`
	- `README.md`
	- `pubspec.yaml`
	- `pubspec.lock`
	- `italir_pothe.iml`
	- `android/`
	- `ios/`
	- `lib/`
	- `linux/`
	- `macos/`
	- `test/`
	- `web/`
	- `windows/`

- Under `lib/`, initialize with this exact structure:
	- `lib/main.dart`
	- `lib/core/`
	- `lib/core/bindings/`
	- `lib/core/bootstrap/`
	- `lib/core/localization/`
	- `lib/core/localization/app_translations.dart`
	- `lib/core/models/`
	- `lib/core/services/`
	- `lib/core/services/api_client.dart`
	- `lib/core/services/api_error_handler.dart`
	- `lib/core/services/auth_service.dart`
	- `lib/core/themes/`
	- `lib/core/utils/`
	- `lib/core/widgets/`
	- `lib/modules/`
	- `lib/routes/`
	- `lib/routes/app_pages.dart`
	- `lib/routes/app_routes.dart`

- Every new module created under `lib/modules/` must include dedicated folders/files for model, service, controller, and view.
- Keep `Core` for cross-cutting concerns and shared app infrastructure.
- Keep `Routes` as the single source for route names and page registration.
- Keep the folders and the files empty. no need to generate boilerplate code for the files, only create the empty files and folders.


## Code Quality Rules

- Avoid redundant wrapper methods.
- Do not create pass-through methods that only call another method without adding logic.
- Do not create both `fromJson` and `fromMap` unless they have distinct responsibilities.
- Prefer a single source of truth for model parsing.
- Every method must have a clear responsibility (transformation, validation, or abstraction).
- If a method only forwards parameters without modification, it should be removed.
- Redundant abstraction is not allowed.
- Wrapper methods must only exist if they introduce transformation or domain logic.
- use the direct values from the backend response.
refer to the postman sollection json for the variable names.
- Do not use list of keys/guesses to read from the json, only use the documented variable names from the postman collection json.
- Only use backend data to hydrate existing UI models, do not create new models or UI elements based on the backend response. 
- IMPORTANT: if the json does not contain the proper variable names implement a single variable name and place comment stating ("Postman does not contain the proper variable name") and IMMEDIATELY add comments and report back such empty states to the user.
- Direct delegation without logic is considered a violation.