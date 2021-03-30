# API/Server Documentation
## Development setup

```zsh
$ npm install
$ npm run setup
$ npm run dev
```

The API will now be available at `localhost:3333`.

### Commands
```zsh
$ npm run setup   - Run database migrations and seeders
$ npm run build   - Build the application for production
$ npm run start   - Start thes server in production mode
$ npm run dev     - Start the server in development mode
$ npm run lint    - Run ESLint on all source files
$ npm run format  - Format all source files using Prettier
$ npm run test    - Run all tests defined in `test/`
```

### Frameworks and Database
At this moment, the lightweight `SQlite3` database is in use for development.
Since the framework [adonisjs](https://adonisjs.com/) is used to create the
backend functionality for the database. All dependencies and setup will be made
automatically after running `npm install`.
`npm run setup` will run database migrations and seed the database with test
data (only in development mode).

When needed to migrate to another database, for instance `MongoDB`, it is
possible to do so within `AdonisJS`, for how this is done, check out [AdonisJS
docs](https://adonisjs.com/docs/4.1/migrations).

### Data validators
The api has its own validator that can be found in
`app/Validators/UserValidator.js`.

At this moment, the following rules are set:
```ts
public schema = schema.create({
    email: schema.string({}, [
        rules.email(),
    ]),
    password: schema.string({}, [
        rules.minLength(8),
        rules.maxLength(256),
    ]),
})
```

We validate so that the password is in between the interval `8` - `256`.
As well using the rule `rules.email()` so that the input coming is in the
correct format. For e.g., `example@examples.se`.

### Testing

## Endpoints
All endpoints expect and return data in JSON format. Note that the base URL of
the API is omitted from the endpoints below.

### Login
```
POST /api/v1/users/login
```

#### Request data
- `email` - string, required
- `password` - string, required

#### Response data
##### Success
```json
{
    "type": "bearer",
    "token": "<opaque token>"
}
```

##### Error
Based on the `email` and `password` request contents, the `errors` array might
contain different messages. E.g. specifying an email that does not follow the
format of an email will return another validator error.

```json
{
    "errors": [
        {
            "message": "Invalid user credentials"
        }
    ]
}
```
