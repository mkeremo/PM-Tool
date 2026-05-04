# PM Desktop Assistant (MVP)

## Goal
Build a macOS desktop app for Project Managers that monitors Outlook inbox and surfaces direct-email reminders until each email is acknowledged.

## MVP Scope

### Primary user story
As a Project Manager, I want a desktop app that checks Outlook emails and notifies me when an email is sent directly to me, so I don't miss important requests.

### In-scope behaviors
1. **Outlook monitoring**
   - Connect to Microsoft 365 mailbox using Microsoft Graph API.
   - Poll inbox on a fixed schedule (e.g., every 1-2 minutes for MVP).
   - Detect emails where the PM is in the **To** field (direct recipient), excluding CC-only emails.

2. **Mac notification flow**
   - Show a macOS notification pop-up for each new unacknowledged direct email.
   - Notification has two actions:
     - **Close for now**: snooze and show again in 15 minutes.
     - **Check**: mark as done/acknowledged and stop reminders.

3. **15-minute reminder loop**
   - Every unacknowledged email re-triggers notification every 15 minutes.
   - Reminder loop stops only when user clicks **Check**.

4. **Local state persistence**
   - Store email reminder state locally (e.g., SQLite or JSON) so reminders survive app restart.

## How to use (for non-technical PM users)

### Quick start
1. Download the app package to your Mac.
2. Double-click `launcher.command`.
3. If macOS asks for permission to run it, click **Open**.
4. The launcher opens this guide automatically and shows a "ready" notification.

### First-time setup
1. Sign in with your Microsoft 365 account when prompted.
2. Allow mailbox read access (`Mail.Read`) so the app can detect direct emails.
3. Keep the app running in the background.

### Daily usage
- When a direct email arrives, you will see a notification with two buttons:
  - **Close for now**: hides the alert and reminds you again in 15 minutes.
  - **Check**: marks the reminder as done and stops future alerts for that email.
- If you do nothing, reminders continue every 15 minutes.

### Troubleshooting
- If notifications do not appear:
  1. Open **System Settings → Notifications**.
  2. Find **PM Desktop Assistant** and enable notifications.
- If the launcher does not open:
  1. Right-click `launcher.command` and select **Open**.
  2. Confirm macOS security prompt.

## Suggested architecture (MVP)

### App shell (macOS)
- **Framework options**
  - Swift + SwiftUI (native macOS app, best OS integration), or
  - Electron/Tauri (cross-platform, easier web-stack onboarding).

### Agent design
For MVP, use **one lightweight local agent service** with clear modules:

1. **Inbox Agent**
   - Pulls message metadata from Microsoft Graph.
   - Normalizes message identity and recipient fields.

2. **Reminder Agent**
   - Applies reminder policy (15-minute intervals).
   - Decides when to schedule next notification.

3. **Action Agent**
   - Handles notification button actions:
     - snooze
     - check complete

> You can run these as separate classes/services in one process now. If scale grows, split into independent workers later.

## Data model (minimum)

`ReminderItem`
- `message_id` (string, unique)
- `subject` (string)
- `sender` (string)
- `received_at` (datetime)
- `is_direct_to_me` (bool)
- `status` (`pending` | `done`)
- `next_notify_at` (datetime)
- `last_notified_at` (datetime | null)
- `snooze_minutes` (int, default 15)

## Functional flow
1. User signs in with Microsoft account (OAuth device code or interactive flow).
2. Inbox Agent polls unread/recent messages.
3. For each direct email not in local state:
   - create `ReminderItem(status=pending, next_notify_at=now)`.
4. Reminder Agent checks due items every minute.
5. If due:
   - show notification with **Close for now** and **Check**.
6. If **Close for now**:
   - set `next_notify_at = now + 15 minutes`.
7. If **Check**:
   - set `status = done` and clear future reminders.

## Security and compliance notes
- Use Microsoft identity platform + least-privilege scopes (`Mail.Read` for MVP).
- Store tokens in macOS Keychain (or secure credential vault).
- Avoid storing full email body in MVP; only metadata needed for reminders.
- Add audit logs for notification actions (useful before org-wide rollout).

## Included launcher
- File: `launcher.command`
- Purpose: one-click starter for non-technical PM users.
- What it does:
  1. opens this guide in TextEdit,
  2. writes a simple startup log to `logs/pm-desktop-assistant.log`,
  3. shows a macOS "ready" notification.

## Rollout plan
1. **Pilot**: 1-3 PM users on macOS.
2. **Feedback loop**: tune polling interval, reminder UX, false positives.
3. **Phase 2**: team/shared mailbox rules, priority detection, SLA dashboards.
4. **Org rollout**: package with MDM distribution (Jamf/Intune) for all PMs.

## Proposed MVP backlog
- [ ] macOS app scaffold
- [ ] Microsoft sign-in + token handling
- [ ] Inbox polling service
- [ ] Direct-recipient filter logic
- [ ] Notification UI with two actions
- [ ] 15-minute reschedule engine
- [ ] Local persistence for reminder state
- [ ] Basic settings (poll interval, quiet hours)
- [ ] Pilot packaging + install guide

## Success criteria
- PM receives notification for new direct emails within 2 minutes of arrival.
- Unacknowledged emails re-notify every 15 minutes.
- Clicking **Check** reliably suppresses future notifications for that email.
- App restarts without losing pending reminders.

