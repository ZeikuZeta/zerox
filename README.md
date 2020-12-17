# ZeroX

WORK-IN-PROGRESS / Not functionnal.

ZeroX is a API First WIP multi-tenant (role per user in tenant) Backend as a Service solution based on postgreSQL, postgREST, RabbitMQ.

## Goals

### Deploy without any configuration a business agnostic back-end with multi-tenancy enabled.

- [ ] Register and log-in via API.
- [ ] Create tenancy (Organization) via API with user.
- [ ] Create application via API with super-user.
- [ ] Create offer via API with super-user wich relied on an application.
- [ ] Deploy data schema of a application via API with super-user in a declarative way. (Multi-tenancy are managed by ZeroX not you).
- [ ] Subscription to offer via API with user (generate subscription secret key for that subscription).
- [ ] Start services with your code (with application secret key).
- [ ] Handle your customer via your services via the subscription secret key.

### Deployment

- [ ] Docker-compose
- [ ] Kubernetes

### Others

- [ ] Let super-user define roles for application.
- [ ] Monitoring and alerting.
- [ ] Nested multi-tenancy and reseller.
- [ ] GraphQL.

## Multi-tenant approach

Multi tenancy is enabled in ZeroX by Orgnization and Account entity and row level security inside postgreSQL.
