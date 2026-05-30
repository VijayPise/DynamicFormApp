# DynamicFormApp

# README.md

# Dynamic Form Renderer – SwiftUI SDUI

## Overview

This project implements a Server-Driven UI (SDUI) form renderer in SwiftUI.
The application dynamically renders form screens using a JSON configuration instead of hardcoded UI components.

The goal was to create a scalable, reusable, and extensible architecture where UI behavior, validation, styling, and interactions are fully controlled through backend-driven JSON payloads.

---

# Overall Approach & Architecture

## Architecture

The project follows a lightweight MVVM-inspired architecture:

* **Model Layer**

  * Codable-based JSON parsing
  * Dynamic field definitions
  * Validation metadata
  * Theming configuration

* **View Layer**

  * Reusable SwiftUI components
  * Dynamic field rendering using enums and switch-based composition
  * Centralized styling and theme support

* **ViewModel Layer**

  * Form state management
  * Validation handling
  * Dynamic value storage
  * Submission preparation

---

# Core Design Decisions

## 1. Dynamic Rendering via Field Types

Instead of creating individual screens manually, fields are rendered dynamically based on:

```json id="d0gx18"
"type": "TEXT",
"subtype": "MULTILINE"
```

This allows:

* Easier backend-driven UI updates
* Reduced frontend release dependency
* Reusable form components

---

## 2. Flexible Value Storage

Form values are stored in:

```swift id="itvcma"
[String: Any]
```

This was chosen because different field types require different value types:

* String
* Bool
* Array<String>
* Numbers

This approach simplified dynamic rendering and submission handling.

---

## 3. Reusable Components

Each field type was separated into reusable SwiftUI views:

* Text Input
* Checkbox
* Dropdown
* Multi-select Dropdown
* Validation View

This improved:

* Readability
* Maintainability
* Scalability

---

# Product Decisions & Edge Cases

## 1. Missing or Invalid Optional Data

### Decision

If optional JSON values are missing (e.g. placeholder, metadata, validation), the UI falls back to safe defaults instead of crashing.

### Why

Backend-driven systems may evolve over time, and defensive rendering improves app stability.

Example:

```swift id="0zl6df"
field.placeholder ?? ""
```

---

## 2. Max-Length Enforcement

### Decision

Typing is prevented beyond the configured `max_length`.

### Why

This creates immediate feedback and avoids invalid state accumulation.

Example:

```swift id="7cgzcf"
String(newValue.prefix(maxLength))
```

---

## 3. Validation Timing

### Decision

Validation errors are shown only after user interaction/submission instead of immediately on screen load.

### Why

Showing validation instantly creates poor UX and overwhelms users before interaction.

---

## 4. Multi-Select Dropdown Handling

### Decision

SwiftUI `Picker` does not support multi-selection, so a custom sheet-based selector was implemented.

### Why

This provided:

* Better UX
* Scalability
* Cleaner interaction patterns
* Native SwiftUI behavior

---

# Dynamic Features Implemented

* Dynamic field rendering
* Runtime validation
* Required field validation
* Max-length validation
* Dynamic theming
* Clickable legal links
* Multi-selection dropdowns
* URL input handling
* Secure/password fields
* Number-only fields
* Runtime metadata-driven styling

---

# What I Would Improve With More Time

## 1. Form Dependency System

Add support for:

* Conditional visibility
* Dependent fields
* Dynamic enable/disable logic

Example:

* Show "State" only after selecting "Country"

---

## 2. Strongly Typed Form State

Currently form values use:

```swift id="kmbmku"
[String: Any]
```

With more time I would introduce:

* Type-safe wrappers
* Generic field state containers
* Better compile-time safety

---

## 3. Better Validation Engine

Potential improvements:

* Regex validation
* Async/server validation
* Validation pipelines
* Reusable validators

---

## 4. Accessibility Improvements

Would add:

* VoiceOver optimization
* Dynamic Type support
* Accessibility identifiers
* Better keyboard navigation

---

## 5. Unit Testing

I would expand:

* JSON decoding tests
* Validation tests
* Dynamic rendering tests
* Snapshot testing

---

# Challenges Faced

## 1. Multi-Selection Dropdown in SwiftUI

### Issue

SwiftUI’s native `Picker` does not support multiple selection.

### Solution

Implemented a custom sheet-based selection UI using:

* `List`
* Checkmark selection
* Local state synchronization

---

## 2. Dynamic Styling with SwiftUI Controls

### Issue

Controls like `.roundedBorder` do not support custom border colors.

### Solution

Replaced default styles with custom overlays using:

```swift id="wholc4"
RoundedRectangle().stroke(...)
```

This enabled fully dynamic theming from JSON.

---

## 3. Clickable Hyperlinks Inside Labels

### Issue

Checkbox labels needed partially clickable legal text.

### Solution

Used `AttributedString` with dynamic link metadata.

---

# AI Collaboration

AI-assisted development tools were used during implementation for:

* SwiftUI scaffolding
* Architecture suggestions
* Debugging assistance
* Boilerplate generation
* Refactoring guidance

All generated code was manually reviewed, modified, and validated before integration.

See:

* `AI_COLLABORATION_LOG.md`

---

# Tech Stack

* Swift
* SwiftUI
* MVVM
* Codable
* Dynamic JSON Rendering

---

# Final Notes

The primary focus of this implementation was:

* Scalability
* Maintainability
* Extensibility
* Runtime flexibility
* Clean SwiftUI composition

The architecture is intentionally designed to support future backend-driven UI expansion with minimal frontend changes.
