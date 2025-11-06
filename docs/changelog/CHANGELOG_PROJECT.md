# Gerobaks Project Changelog

## Unreleased

### Added

- Laravel Sanctum authentication (token issuing on register/login, logout endpoint)
- Role-based route protection via custom `RoleMiddleware`
- User extended profile fields exposed & fillable
- API Resource: `UserResource` for consistent user serialization
- Protected & refactored routes (auth, orders, payments, notifications, chat, dashboard)
- Flutter: `auth_api_service.dart` (register/login/me/logout + token persistence)
- Flutter: Automatic Authorization header injection in `ApiClient`
- OrderService (finite state machine for order status transitions + completion rewards & ledger commission entry)
- PaymentService (`mark-paid` workflow with idempotency + automatic ledger entry)
- API Resources: `OrderResource`, `PaymentResource`, `RatingResource`, `ScheduleResource`

### Changed

- `AuthController` responses now wrap data under `data` envelope & return token
- Tracking POST now requires authenticated Mitra role
- Order creation restricted to end_user; assignment & status updates restricted to mitra/admin
- Order status changes now validated against allowed transition map (via OrderService)
- Payment mark-paid now enforces idempotent state change and generates ledger entry

### Security

- Revokes previous tokens on login to prevent token sprawl
- Middleware-based access control for sensitive endpoints

### Pending (Planned Next)

- Notification pagination & read optimization
- Additional API Resources (remaining: Notification, Balance, Chat, Tracking, Ledger)
- Ownership & authorization enhancements (order rating eligibility, ledger access scoping)
- Database indexing (orders.status, orders.mitra_id, payments.status, notifications.user_id)
- Test coverage (auth, order transitions, payment idempotency, ledger integrity)

---

Generated automatically by implementation step on $(date).
