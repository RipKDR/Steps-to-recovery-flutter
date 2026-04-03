# Documentation Sources

This document lists all documentation sources fetched by the self-evolving agent.

## Primary Sources

### Flutter

| Resource | URL | Fetch Frequency | Cache TTL |
|----------|-----|-----------------|-----------|
| API Docs | https://api.flutter.dev/flutter/ | Daily | 24 hours |
| Docs Site | https://docs.flutter.dev/ | Daily | 24 hours |
| GitHub | https://github.com/flutter/flutter | Weekly | 7 days |
| Releases | https://docs.flutter.dev/release | Weekly | 7 days |

**Key Pages:**
- Installation: https://docs.flutter.dev/get-started/install
- Testing: https://docs.flutter.dev/testing/overview
- Performance: https://docs.flutter.dev/perf/rendering-performance
- State Management: https://docs.flutter.dev/data-and-backend/state-mgmt

**Fetch Script:**
```powershell
.\fetch-docs.ps1 -Source flutter
```

### Dart

| Resource | URL | Fetch Frequency | Cache TTL |
|----------|-----|-----------------|-----------|
| Language Tour | https://dart.dev/guides/language/language-tour | Daily | 24 hours |
| Library Tour | https://dart.dev/guides/libraries/library-tour | Daily | 24 hours |
| API Docs | https://api.dart.dev/ | Daily | 24 hours |
| GitHub | https://github.com/dart-lang/sdk | Weekly | 7 days |

**Key Pages:**
- Null Safety: https://dart.dev/null-safety
- Async: https://dart.dev/codelabs/async-await
- Generics: https://dart.dev/guides/language/language-tour#generics

**Fetch Script:**
```powershell
.\fetch-docs.ps1 -Source dart
```

### Pub.dev Packages

| Resource | URL | Fetch Frequency | Cache TTL |
|----------|-----|-----------------|-----------|
| Package Site | https://pub.dev/ | Daily | 24 hours |
| API Docs | https://pub.dev/documentation/ | Daily | 24 hours |

**Tracked Packages** (from pubspec.yaml):
- go_router
- shared_preferences
- encrypt
- flutter_secure_storage
- local_auth
- flutter_local_notifications
- workmanager
- http
- supabase_flutter
- google_generative_ai
- sentry_flutter
- flutter_animate
- fl_chart
- percent_indicator
- smooth_page_indicator
- flutter_form_builder
- form_builder_validators

**Fetch Script:**
```powershell
.\fetch-docs.ps1 -Source pubdev
.\fetch-docs.ps1 -Package go_router
```

### Qwen Code Framework

| Resource | Location | Fetch Frequency | Cache TTL |
|----------|----------|-----------------|-----------|
| AGENTS.md | Project root | Daily | 48 hours |
| QWEN.md | Project root | Daily | 48 hours |
| Skills | .qwen/skills/ | Daily | 48 hours |
| Agents | .qwen/agents/ | Daily | 48 hours |

**Fetch Script:**
```powershell
.\fetch-docs.ps1 -Source qwen
```

## Secondary Sources

### Supabase

| Resource | URL | Fetch Frequency | Cache TTL |
|----------|-----|-----------------|-----------|
| Dart Client | https://supabase.com/docs/reference/dart | Weekly | 7 days |
| Database Guide | https://supabase.com/docs/guides/database | Weekly | 7 days |

**Fetch Script:**
```powershell
.\fetch-docs.ps1 -Source supabase
```

### Azure

| Resource | URL | Fetch Frequency | Cache TTL |
|----------|-----|-----------------|-----------|
| Azure SDK | https://learn.microsoft.com/azure/developer | Weekly | 7 days |

**Fetch Script:**
```powershell
.\fetch-docs.ps1 -Source azure
```

### Google AI

| Resource | URL | Fetch Frequency | Cache TTL |
|----------|-----|-----------------|-----------|
| Gemini API | https://ai.google.dev/docs | Weekly | 7 days |

**Fetch Script:**
```powershell
.\fetch-docs.ps1 -Source googleai
```

## Fetch Configuration

### Default Schedule

| Source | Schedule | Time |
|--------|----------|------|
| Flutter | Daily | 6:00 AM |
| Dart | Daily | 6:00 AM |
| Pub.dev | Daily | 6:00 AM |
| Qwen | Daily | 6:00 AM |
| Supabase | Weekly | Sunday 2:00 AM |
| Azure | Weekly | Sunday 2:00 AM |
| Google AI | Weekly | Sunday 2:00 AM |

### Manual Fetch

```powershell
# Fetch all sources
.\fetch-docs.ps1 -All

# Fetch specific source
.\fetch-docs.ps1 -Source flutter

# Fetch specific package
.\fetch-docs.ps1 -Package go_router

# Force refresh (ignore cache)
.\fetch-docs.ps1 -All -Force

# Dry run (show what would be fetched)
.\fetch-docs.ps1 -All -DryRun
```

## Cache Management

### Cache Location

```
.qwen/skills/self-evolving-agent/doc-cache/
├── flutter/
├── dart/
├── pubdev/
│   └── {package-name}/
├── qwen/
│   ├── agents/
│   └── skills/
├── supabase/
├── azure/
└── googleai/
```

### Cache Validation

Each cache directory contains an `index.json`:

```json
{
  "Source": "Flutter",
  "FetchedAt": "2026-04-02T06:00:00",
  "Files": ["api-index.json", "install-guide.md"],
  "Version": "latest"
}
```

### Cache Clearing

```powershell
# Clear all caches
Remove-Item -Path ".qwen\skills\self-evolving-agent\doc-cache\*" -Recurse -Force

# Clear specific cache
Remove-Item -Path ".qwen\skills\self-evolving-agent\doc-cache\flutter\*" -Recurse -Force
```

## Documentation Processing

### HTML to Markdown

Fetched HTML is converted to markdown for easier processing:

```powershell
function Convert-HtmlToMarkdown {
    param($htmlContent)
    
    # Use web_fetch or similar tool
    # Strip HTML tags
    # Convert links to markdown format
    # Preserve code blocks
}
```

### Content Extraction

Extract relevant sections:

1. **API Documentation**: Function signatures, parameters, return types
2. **Guides**: Step-by-step instructions
3. **Best Practices**: Recommended patterns
4. **Migration Guides**: Version upgrade instructions

### Indexing

Create searchable index:

```json
{
  "keywords": ["widget", "state", "lifecycle"],
  "topics": ["State Management", "Widget Lifecycle"],
  "references": ["StatefulWidget", "initState", "dispose"]
}
```

## Update Notifications

### Change Detection

Monitor for documentation changes:

```powershell
function Test-DocumentationChanged {
    param($source, $cachedContent, $newContent)
    
    # Compare hashes
    $oldHash = Get-FileHash -InputStream $cachedContent
    $newHash = Get-FileHash -InputStream $newContent
    
    return $oldHash.Hash -ne $newHash.Hash
}
```

### Alert on Breaking Changes

Watch for keywords:
- "Breaking change"
- "Deprecated"
- "Removed"
- "Migration required"

## Offline Mode

When network is unavailable:

1. Use cached documentation
2. Mark as potentially outdated
3. Queue fetch for when online
4. Warn user if cache is stale

---

**Version:** 1.0.0  
**Last Updated:** 2026-04-02  
**Maintained By:** Self-Evolving Agent
