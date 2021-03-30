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

---

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

---

### Fetch all nations
```
GET /api/v1/nations
```

#### Request data
None

#### Response data
##### Success
A list of all available nations and information about them.

```json
[
    {
        "id": 3,
        "oid": 405,
        "name": "Norrlands nation",
        "short_name": "Norrlands",
        "description": "Välkommen till världens största studentnation!..",
        "address": "Västra Ågatan 13, 75309 Uppsala",
        "max_capacity": 150,
        "estimated_people_count": 130,
        "activity_level": 3,
        "icon_img_src": null,
        "cover_img_src": null,
        "accent_color": "#e20e17"
    }
]
```

---

##### Error
None

### Fetch a single nation
```
GET /api/v1/nations/:oid
```

#### Request data
None

#### Response data
##### Success
A single nation and its data.

```json
{
    "id": 3,
    "oid": 405,
    "name": "Norrlands nation",
    "short_name": "Norrlands",
    "description": "Välkommen till världens största studentnation!..",
    "address": "Västra Ågatan 13, 75309 Uppsala",
    "max_capacity": 150,
    "estimated_people_count": 130,
    "activity_level": 3,
    "icon_img_src": null,
    "cover_img_src": null,
    "accent_color": "#e20e17"
}
```

##### Error
E.g. if trying to fetch a student nation with `oid` 200 that does not exist:

```json
{
    "status": 404,
    "success": false,
    "message": "Could not find student nation with id: 200"
}
```

---

### Update a nation
**TODO: Update documentation when the endpoint has been implemented fully**

```
PUT /api/v1/nations/:oid
```
#### Authentication
This endpoint is protected and requires a valid token. Tokens **must** be set in
the `Authorization` header:

```
Authorization: Bearer <token>
```

#### Request data
The request data can contain any (and multiple) of the following properties:

- `name`
- `short_name`
- `description`
- `address`
- `max_capacity`
- `estimated_people_count`
- `activity_level`
- `icon_img_src`
- `cover_img_src`
- `accent_color`

Note that `id` and `oid` can not be updated.

The data specified will be merged with the existing data in the database,
overwriting the values specified in the request.

E.g:
```json
{
    "name": "New name",
    "accent_color": "#abcabc"
}
```

will update the name and accent color of the nation.

#### Response data
##### Success
```json
{
    "status": 200,
    "success": true,
    "message": "Successfully updated student nation with id: <oid>"
}
```

##### Error
E.g. if trying to fetch a student nation with `oid` 200 that does not exist:

```json
{
    "status": 404,
    "success": false,
    "message": "Could not find student nation with id: 200"
}
```

If trying to fetch a student nation with `oid` 200 without specifying a
valid token:

```json
{
    "errors": [
        {
            "message": "E_UNAUTHORIZED_ACCESS: Unauthorized access"
        }
    ]
}
```
