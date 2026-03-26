# Specialized AI Agents for Steps to Recovery

This directory contains specialized AI agents configured to help with specific aspects of Flutter development for the Steps to Recovery app.

---

## 🤖 Available Agents

| Agent | Color | Purpose |
|-------|-------|---------|
| **memory-loader** | ⚪ White | **AUTO-LOADS FIRST** — Loads `.remember/` memory system every session |
| **prompt-enhancer** | Auto | Clarifies vague requests, adds requirements |
| **flutter-widget-builder** | 🔵 Blue | Builds Material 3 widgets with recovery app patterns |
| **flutter-test-architect** | 🟢 Green | Writes comprehensive tests (unit, widget, integration) |
| **service-architect** | 🟣 Purple | Creates/maintains the 10 singleton services |
| **ai-ml-integration** | 🟠 Orange | AI companion features, Google Generative AI, Gemini |
| **security-specialist** | 🔴 Red | AES-256 encryption, biometric auth, privacy patterns |

---

## 📋 Agent Descriptions

### **memory-loader** ⚪
**When to use**: **ALWAYS** — Runs automatically at the start of every session

**Purpose**: Loads the `.remember/` memory system to provide persistent context across all conversations.

**What it loads** (in order):
1. `.remember/SOUL.md` — Agent identity and role
2. `.remember/USER.md` — User preferences and working style
3. `.remember/memory/project-state.md` — Current project state
4. `.remember/memory/YYYY-MM-DD.md` — Recent session notes
5. `.remember/logs/autonomous/memory.md` — HOT memory (≤100 lines)

**What it logs**:
- Corrections → `logs/autonomous/corrections.md`
- Preferences → `logs/autonomous/memory.md`
- Project lessons → `logs/autonomous/projects/steps-to-recovery.md`
- Domain lessons → `logs/autonomous/domains/<domain>.md`
- Reflections → `logs/autonomous/reflections.md`

---

### **prompt-enhancer** (Built-in)
**When to use**: When you have a vague request that needs clarification

**Example triggers**:
- "Help me build something for..."
- "I need a feature that..."
- "Make it better"

---

### **flutter-widget-builder** 🔵
**When to use**: Building UI components, screens, widgets

**Example triggers**:
- "Create a screen for..."
- "Build a widget that..."
- "Add a UI component..."
- "Design a card for..."

**Expertise**:
- Material 3 design with dark theme
- Privacy-first, trauma-informed UX
- Performance optimization (const constructors)
- Accessibility (semantic labels)
- Responsive layouts

---

### **flutter-test-architect** 🟢
**When to use**: Writing tests, improving coverage

**Example triggers**:
- "Write tests for..."
- "I need test coverage on..."
- "How do I test..."
- "Create golden tests for..."

**Expertise**:
- Unit tests (services, models)
- Widget tests (screens, components)
- Integration tests (E2E flows)
- Mocktail patterns (no build_runner)
- Golden tests (visual regression)

**Proactive**: Flags untested services (currently: `SyncService`)

---

### **service-architect** 🟣
**When to use**: Creating or modifying services

**Example triggers**:
- "Create a new service for..."
- "Refactor the database service..."
- "How should I structure..."
- "Add CRUD operations to..."

**Expertise**:
- Singleton service pattern
- Dependency injection
- CRUD operations
- Service communication patterns
- Error handling with logging

**Knows the 10 services**:
1. PreferencesService
2. EncryptionService
3. DatabaseService
4. AppStateService
5. ConnectivityService
6. NotificationService
7. SyncService
8. AiService
9. LoggerService
10. AnalyticsService

---

### **ai-ml-integration** 🟠
**When to use**: AI companion features, Google AI integration

**Example triggers**:
- "Add AI chat feature..."
- "Integrate Gemini..."
- "AI settings screen..."
- "Streaming responses..."

**Expertise**:
- Google Generative AI SDK
- Prompt engineering for recovery
- Streaming responses
- Rate limiting
- Content safety
- Crisis protocols

---

### **security-specialist** 🔴
**When to use**: Encryption, biometric auth, privacy features

**Example triggers**:
- "Encrypt journal entries..."
- "Add biometric lock..."
- "Secure the sponsor data..."
- "Key rotation..."

**Expertise**:
- AES-256 encryption
- flutter_secure_storage
- Biometric authentication (local_auth)
- Privacy patterns
- Secure data storage
- Key management

---

## 🎯 How to Use Agents

### Automatic Trigger
Agents are triggered automatically based on your requests. The system matches your query to the most relevant agent.

### Manual Selection
In your AI chat interface, you can specify which agent to use:

```
@flutter-widget-builder Create a gratitude journal screen
@flutter-test-architect Write tests for the milestone service
@service-architect Create a new achievement service
```

---

## 🧠 Agent Capabilities

### WAL Protocol (Write Ahead of Learning)
All agents log your preferences and corrections to `~/self-improving/` for persistent learning.

### VBR Protocol (Verify Before Reporting)
Agents verify code actually works before saying "done" - they run tests, check analysis.

### Proactive Behaviors
Agents will:
- Flag untested code
- Notice half-wired features
- Suggest improvements
- Learn from repeated patterns

---

## 📁 File Locations

- **Agent definitions**: `.qwen/agents/*.md`
- **Memory system**: `.remember/` (auto-loaded every session)
- **HOT memory**: `.remember/logs/autonomous/memory.md` (≤100 lines, always loaded)
- **Corrections log**: `.remember/logs/autonomous/corrections.md`
- **Reflections log**: `.remember/logs/autonomous/reflections.md`
- **Project memory**: `.remember/memory/project-state.md`
- **Daily notes**: `.remember/memory/YYYY-MM-DD.md`

---

## 🚀 Best Practices

### For Users
1. **Be specific** - Agents work better with clear requirements
2. **Review proactively** - Agents may suggest things you haven't asked for
3. **Correct openly** - Agents learn from corrections
4. **Use the right agent** - Match your task to agent expertise

### For Agents
1. **Preserve intent** - Never change what the user wants
2. **Verify before done** - Actually test the code
3. **Log learnings** - Write corrections to memory
4. **Be resourceful** - Try multiple approaches before asking for help

---

## 🔄 Agent Evolution

Agents improve over time through:
- **Corrections** - When you correct an agent, it's logged
- **Patterns** - Repeated requests trigger automation proposals
- **Preferences** - Your style choices are remembered
- **Projects** - Domain knowledge accumulates

---

## 📞 Need Help?

If an agent isn't behaving as expected:
1. Check the agent definition in `.qwen/agents/`
2. Review `~/self-improving/` for learned patterns
3. Be explicit about requirements
4. Provide corrections - they're logged and learned

---

**Created**: 2026-03-27  
**Last Updated**: 2026-03-27  
**Total Agents**: 7 (including memory-loader)
