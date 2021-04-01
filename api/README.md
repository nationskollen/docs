# API/Server Documentation
## Development setup
[Setup guide](https://github.com/dsp-krabby/server/tree/main#development)

### Frameworks and Database
At this moment, the lightweight `SQlite3` database is in use for development.
Since the framework [AdonisJS](https://adonisjs.com/) is used to create the
backend functionality for the database. All dependencies and setup will be made
automatically after running `npm install`.
`npm run setup` will run database migrations and seed the database with test
data (only in development mode).

Switching databases is really easy and is explained in the [AdonisJS
docs](https://preview.adonisjs.com/guides/database/setup)

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
correct format, e.g. `example@examples.se`.


### Testing

## Activity levels
Activity levels update dynamically depending on how much estimated people are
reported into the system. As well depending on the max capacity that is set for
a given Nation.

The following activity levels are present in the system:

- Closed
  - Can only be initiated by a `PUT /nations/:oid/close`
- Low
- Medium
- High
- VeryHigh
- Full

Example:
```ts
// max_capacity is 200
// estimated_people_count for this example is 100
// activity level is 0.5 => Medium (+- High, Low)

{
	"change": 80
}

// estimated_people_count becomes 180
// activity rises up to VeryHigh
```


## Endpoints
### Content type
All endpoints expect and return data in JSON format.

### Authentication
Authentication is done using Bearer tokens by setting the `Authorization` header:
```
Authorization: Bearer <token>
```

Some routes requires authorization and the Bearer token **must** be set for the
request to be valid. Different users have different permissions. These
permissions are called scopes and the required scopes are defined in the
"Authentication" section of each endpoint.

> **Note that users may only modify the nation that they are part of**.

If the specified token is not valid or does not have permisson to perform the
action, the following data will be received in the response:

```json
{
    "errors": [
        {
            "message": "E_UNAUTHORIZED_ACCESS: Unauthorized access"
        }
    ]
}
```

### Standard error response format
The format for all kind of request errors is as follows:

```json
{
    "errors": [
        {
            "message": "<validation error>"
        }
    ]
}
```

Response data validation errors are more specific as to what causes the error:

```json
{
    "errors": [
        {
            "rule": "<rule>",
            "field": "<parameter>",
            "message": "<validation error>"
        }
    ]
}
```

The `errors` array can contain an arbitrary amount of errors.

---

### Login

```
POST /api/v1/users/login
```

#### Authentication scopes
None

#### Parameters
- `email` - string, required
- `password` - string, required

#### Success response
```json
{
    "type": "bearer",
    "token": "<opaque token>",
    "scope": "<admin|staff|none>",
    "oid": <oid>
}
```

`oid` is the id of the nation that this user is a part of (as staff or admin).
If the value is `-1`, it means that the user does not belong to any nation and
can not make authenticated requests.

#### Error status codes
- `422` - Response data vaidation error

---

### Fetch all nations
```
GET /api/v1/nations
```

#### Authentication scopes
None

#### Parameters
None

#### Success response
A list of all available nations and information about them. An empty array will
be returned if no nations are available.

```json
[
    {
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

#### Error status codes
None

---

### Fetch a single nation
```
GET /api/v1/nations/:oid
```

#### Authentication scopes
None

#### Parameters
None

#### Success response
A single nation and its data.

```json
{
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

#### Error status codes
- `404` - Nation not found

---

### Update a nation
```
PUT /api/v1/nations/:oid
```

#### Authentication scopes
- `admin`

#### Parameters
The request data can contain any (and multiple) of the following properties:

- `name`
- `short_name`
- `description`
- `address`
- `max_capacity`
- `accent_color`

The data specified will be merged with the existing data in the database,
overwriting the values specified in the request.

#### Success response
```json
{
    "status": 200,
    "success": true,
    "message": "<success message>"
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Nation not found
- `422` - Response data vaidation error

---

### Update nation activity
```
PUT /api/v1/nations/:oid/activity
```

#### Authentication scopes
- `staff`
- `admin`

#### Parameters
- `change` - signed number, required

The resulting people count will be clamped between `0` and the max capacity of
the nation.

#### Success response
```json
{
    "estimated_people_count": <count>,
    "activity_level": <level>
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Nation not found
- `422` - Response data vaidation error
