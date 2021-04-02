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

## Endpoint information
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

### Activity levels
Activity levels update dynamically depending on how much estimated people are
reported into the system. As well depending on the max capacity that is set for
a given Nation.

The following activity levels are present in the system:

- `0` - Closed
  * Can only be initiated by a `PUT /nations/:oid/close`
- `1` - Low
- `2` - Medium
- `3` - High
- `4` - Very high
- `5` - Max capacity

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

### Opening hour types
There are two different types of opening hours:
- `0` - `Default` - Regular opening hour on e.g. Monday
- `1` - `Exception` - Holidays, etc.


### Weekday enum
Each day is represented by a number:
- `0` - Monday
- `1` - Tuesday
- `2` - Wednesday
- `3` - Thursday
- `4` - Friday
- `5` - Saturday
- `6` - Sunday

---

## Endpoints

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
        "accent_color": "#e20e17",
        "openingHours":[
            {
                "id": 1,
                "oid": 400,
                "type": 0,
                "day": 0,
                "day_special": null,
                "day_special_date": null,
                "open": "10:30",
                "close": "20:00",
                "is_open": true
            },
            ...
        ],
        "opening_hour_exceptions": [...]
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
    "accent_color": "#e20e17",
    "openingHours":[
        {
            "id": 1,
            "oid": 400,
            "type": 0,
            "day": 0,
            "day_special": null,
            "day_special_date": null,
            "open": "10:30",
            "close": "20:00",
            "is_open": true
        },
        ...
    ],
    "opening_hour_exceptions": [...]
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
The nation containing the updated data.

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
    "accent_color": "#e20e17",
    "openingHours":[
        {
            "id": 1,
            "oid": 400,
            "type": 0,
            "day": 0,
            "day_special": null,
            "day_special_date": null,
            "open": "10:30",
            "close": "20:00",
            "is_open": true
        },
        ...
    ],
    "opening_hour_exceptions": [...]
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


#### Success response
The resulting people count will be clamped between `0` and the max capacity of
the nation.

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

---

### Create opening hour
```
POST /api/v1/nations/:oid/opening_hours
```

#### Authentication scopes
- `admin`

#### Parameters
##### `Default`
- `type` - `0`, required
- `day` - `0-6`, required
- `is_open` - boolean, required
- `open` - time in format `HH:mm`, required if `is_open = true`
- `close` - time in format `HH:mm`, required if `is_open = true`

##### `Exception`
- `type` - `1`, required
- `day_special` - string (e.g. "Christmas Eve"), required
- `day_special_date` - date in format `d/M` (e.g. "24/12"), required
- `is_open` - boolean, required
- `open` - time in format `HH:mm`, required if `is_open = true`
- `close` - time in format `HH:mm`, required if `is_open = true`

#### Success response
The created opening hour.

```json
{
    "id": 1,
    "oid": 400,
    "type": 0,
    "day": 0,
    "day_special": null,
    "day_special_date": null,
    "open": "10:30",
    "close": "20:00",
    "is_open": true
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Nation not found
- `422` - Response data vaidation error

---

### Update opening hour
```
PUT /api/v1/nations/:oid/opening_hours/:id
```

#### Authentication scopes
- `admin`

#### Parameters
The request data can contain the following parameters:

- `type` - `0`/`1`
- `day` - `0-6`, required if `type = 0`
- `day_special` - string (e.g. "Christmas Eve"), required if `type = 1`
- `day_special_date` - date in format `d/M` (e.g. "24/12"), required if `type = 1`
- `is_open` - boolean
- `open` - time in format `HH:mm`, required if `is_open = true`
- `close` - time in format `HH:mm`, required if `is_open = true`

#### Success response
The opening hour containing the updated data.

```json
{
    "id": 1,
    "oid": 400,
    "type": 0,
    "day": 0,
    "day_special": null,
    "day_special_date": null,
    "open": "10:30",
    "close": "20:00",
    "is_open": true
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Nation not found, opening hour not found
- `422` - Response data vaidation error

---

### Delete an opening hour
```
DELETE /api/v1/nations/:oid/opening_hours/:id
```

#### Authentication scopes
- `admin`

#### Parameters
None

#### Success response
None

#### Error status codes
- `401` - Authorization error
- `404` - Nation not found, opening hour not found
