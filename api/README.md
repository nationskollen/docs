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

The `errors` array can contain any amount of errors.

### Activity levels
Activity levels update dynamically depending on how much estimated people are
reported into the system. As well depending on the max capacity that is set for
a given Nation.

The following activity levels are present in the system:

- `0` - Closed
  * Can only be initiated by a `PUT /locations/:id/close`
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

### File uploads
File uploads is requires the following request header:
- `Content-Type: multipart/format`

The following extensions are allowed:
- `png`
- `jpg`
- `jpeg`

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
- `422` - Response data validation error

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
        "oid": 400,
        "name": "Västmanlands-Dala nation",
        "short_name": "V-dala",
        "description": "Enim et doloribus et sed quis exercitationem veritatis...",
        "icon_img_src": "https://cdn.fakercloud.com/avatars/russoedu_128.jpg",
        "cover_img_src": "http://placeimg.com/640/480",
        "accent_color": "#0053a4",
        "locations": [
            {
                "id": 1,
                "nation_id": 400,
                "name": "Bartell LLC",
                "description": "Cupiditate qui rem. Praesentium alias quaerat et in r...",
                "address": "386 Ransom Rest",
                "max_capacity": 719,
                "estimated_people_count": 95,
                "activity_level": 2,
                "is_open": false,
                "cover_img_src": null
            },
            ...
        ]
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
    "oid": 400,
    "name": "Västmanlands-Dala nation",
    "short_name": "V-dala",
    "description": "Enim et doloribus et sed quis exercitationem veritatis...",
    "icon_img_src": "https://cdn.fakercloud.com/avatars/russoedu_128.jpg",
    "cover_img_src": "http://placeimg.com/640/480",
    "accent_color": "#0053a4",
    "locations": [
        {
            "id": 1,
            "nation_id": 400,
            "name": "Bartell LLC",
            "description": "Cupiditate qui rem. Praesentium alias quaerat et in r...",
            "address": "386 Ransom Rest",
            "max_capacity": 719,
            "estimated_people_count": 95,
            "activity_level": 2,
            "is_open": false,
            "cover_img_src": null
        },
        ...
    ]
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
- `accent_color`

The data specified will be merged with the existing data in the database,
overwriting the values specified in the request.

#### Success response
The nation containing the updated data.

```json
{
    "oid": 400,
    "name": "Västmanlands-Dala nation",
    "short_name": "V-dala",
    "description": "Enim et doloribus et sed quis exercitationem veritatis...",
    "icon_img_src": "https://cdn.fakercloud.com/avatars/russoedu_128.jpg",
    "cover_img_src": "http://placeimg.com/640/480",
    "accent_color": "#0053a4",
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Nation not found
- `422` - Response data validation error

---

### Upload nation cover image and/or icon
```
POST /api/v1/nations/:oid/upload
```

#### Authentication scopes
- `admin`

#### Parameters
- `icon` - icon image, optional (binary)
- `cover` - cover image, optional (binary)

#### Success response
The updated nation with the uploaded cover image and/or icon.

```json
{
    "oid": 400,
    "name": "Västmanlands-Dala nation",
    "short_name": "V-dala",
    "description": "Debitis minus molestias fugit ex at et fugiat...",
    "icon_img_src": "http:/0.0.0.0:3333/6d3d87d7974dfc2f68e5699afbb24a672cd3aafb.png",
    "cover_img_src": "http:/0.0.0.0:3333/9a3f7b825cae9166449c7bc6ae8bf127ba7fbea4.png",
    "accent_color": "#0053a4"
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Location not found
- `500` - Image could not be uploaded

---

### Fetch all locations
```
GET /api/v1/nations/:oid/locations
```

#### Authentication scopes
None

#### Parameters
None

#### Success response
A list of all locations for the nation and information about them. An empty array will
be returned if no locations are available.

```json
[
    {
        "id": 1,
        "nation_id": 400,
        "name": "Brown, Ferry and Rohan",
        "description": "Ut nemo id ut minus quia sed nesciunt eveniet ipsum...",
        "address": "535 Kemmer Inlet",
        "max_capacity": 112,
        "estimated_people_count": 19,
        "activity_level": 1,
        "is_open": true,
        "cover_img_src": null,
        "opening_hours": [
            {
                "id": 1,
                "location_id": 1,
                "type": 0,
                "day": 4,
                "day_special": null,
                "day_special_date": null,
                "open": "03:35",
                "close": "18:31",
                "is_open": true
            },
            ...
        ],
        "opening_hour_exceptions": [
            {
                "id": 3,
                "location_id": 1,
                "type": 1,
                "day": null,
                "day_special": "et",
                "day_special_date": "22/7",
                "open": "05:26",
                "close": "17:59",
                "is_open": true
            },
            ...
        ]
    },
]
```

#### Error status codes
- `404` - Nation not found

---

### Fetch a single location
```
GET /api/v1/nations/:oid/locations/:id
```

#### Authentication scopes
None

#### Parameters
None

#### Success response
A single location and its data.

```json
{
    "id": 1,
    "nation_id": 400,
    "name": "Brown, Ferry and Rohan",
    "description": "Ut nemo id ut minus quia sed nesciunt eveniet ipsum...",
    "address": "535 Kemmer Inlet",
    "max_capacity": 112,
    "estimated_people_count": 19,
    "activity_level": 1,
    "is_open": true,
    "cover_img_src": null,
    "opening_hours": [
        {
            "id": 1,
            "location_id": 1,
            "type": 0,
            "day": 4,
            "day_special": null,
            "day_special_date": null,
            "open": "03:35",
            "close": "18:31",
            "is_open": true
        },
        ...
    ],
    "opening_hour_exceptions": [
    {
        "id": 3,
        "location_id": 1,
        "type": 1,
            "day": null,
            "day_special": "et",
            "day_special_date": "22/7",
            "open": "05:26",
            "close": "17:59",
            "is_open": true
        },
        ...
    ]
},
```

#### Error status codes
- `404` - Nation not found, Location not found

---

### Create location
```
POST /api/v1/nations/:oid/locations
```

#### Authentication scopes
- `admin`

#### Parameters
The request data can contain the following parameters:

- `name`: The name for the location that is visible on a nation page
- `description`: A description on this location
- `address`: The address for this location
- `max_capacity`: The maximum amount of people allowed/specified at given location

#### Success response
The created location.

E.g.:
```json
{
    "name": "New Location Name",
    "description": "New Description",
    "address": "Adress streee 24B",
    "max_capacity": 250,
    "nation_id": 400,
    "id": 21
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Location not found
- `422` - Response data validation error

---

### Update a location
```
PUT /api/v1/nations/:oid/locations/:id
```

#### Authentication scopes
- `admin`

#### Parameters
The request data can contain the following parameters:

- `name`: The name for the location that is visible on a nation page
- `description`: A description on this location
- `address`: The address for this location
- `max_capacity`: The maximum amount of people allowed/specified at given location

### Success response

E.g. updating the max_capacity to 250:
```json
{
    "id": 1,
    "nation_id": 400,
    "name": "Location name",
    "description": "In voluptatem molestias accusamus...",
    "address": "254 Cydney Shoals",
--->"max_capacity": 250,
    "estimated_people_count": 0,
    "activity_level": 0,
    "is_open": false,
    "cover_img_src": null
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Location not found
- `422` - Response data validation error

---

### Delete location
```
DELETE /api/v1/nations/:oid/locations/:id
```

#### Authentication scopes
- `admin`

#### Parameters
None

#### Success response
None

#### Error status codes
- `401` - Authorization error
- `404` - Location not found

---

### Update location activity
```
PUT /api/v1/locations/:id/activity
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
    "id": 1,
    "nation_id": 400,
    "name": "Location name",
    "description": "In voluptatem molestias accusamus...",
    "address": "254 Cydney Shoals",
    "max_capacity": 127,
    "estimated_people_count": 127,
    "activity_level": 4,
    "is_open": false,
    "cover_img_src": null
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Location not found
- `422` - Response data validation error

---

### Mark location as open
```
PUT /api/v1/locations/:id/open
```

#### Authentication scopes
- `staff`
- `admin`

#### Parameters
None

#### Success response
The updated location.

```json
{
    "id": 1,
    "nation_id": 400,
    "name": "Location name",
    "description": "In voluptatem molestias accusamus...",
    "address": "254 Cydney Shoals",
    "max_capacity": 127,
    "estimated_people_count": 0,
    "activity_level": 1,
    "is_open": true,
    "cover_img_src": null
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Location not found

---

### Mark location as closed
```
PUT /api/v1/locations/:id/close
```

#### Authentication scopes
- `staff`
- `admin`

#### Parameters
None

#### Success response
The updated location.

```json
{
    "id": 1,
    "nation_id": 400,
    "name": "Location name",
    "description": "In voluptatem molestias accusamus...",
    "address": "254 Cydney Shoals",
    "max_capacity": 127,
    "estimated_people_count": 0,
    "activity_level": 0,
    "is_open": false,
    "cover_img_src": null
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Location not found

---

### Upload location cover image
```
POST /api/v1/locations/:id/upload
```

#### Authentication scopes
- `admin`

#### Parameters
- `cover` - cover image (binary)
- `icon` - icon image (binary)

#### Success response
The updated location with the uploaded cover image.

```json
{
    "id": 1,
    "nation_id": 400,
    "name": "Location name",
    "description": "In voluptatem molestias accusamus...",
    "address": "254 Cydney Shoals",
    "max_capacity": 127,
    "estimated_people_count": 0,
    "activity_level": 0,
    "is_open": false,
    "cover_img_src": "http:/0.0.0.0:3333/d1988c8b8973156897c43fb977a237adc59a09d1.png"
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Location not found
- `500` - Image could not be uploaded

---

### Fetch all opening hours
```
GET /api/v1/locations/:id/hours
```

#### Authentication scopes
None

#### Parameters
None

#### Success response
A list of all opening hours for the location.
An empty array will be returned if no opening hours are available.

```json
[
    {
        "id": 1,
        "location_id": 1,
        "type": 0,
        "day": 4,
        "day_special": null,
        "day_special_date": null,
        "open": "03:35",
        "close": "18:31",
        "is_open": true
    },
    {
        "id": 2,
        "location_id": 1,
        "type": 0,
        "day": 6,
        "day_special": null,
        "day_special_date": null,
        "open": "09:46",
        "close": "22:29",
        "is_open": false
    },
    {
        "id": 3,
        "location_id": 1,
        "type": 1,
        "day": null,
        "day_special": "et",
        "day_special_date": "22/7",
        "open": "05:26",
        "close": "17:59",
        "is_open": true
    }
]
```

#### Error status codes
- `404` - Location not found

---

### Fetch a single opening hour
```
GET /api/v1/locations/:id/hours/:id
```

#### Authentication scopes
None

#### Parameters
None

#### Success response
A single opening hour and its data.

```json
{
    "id": 1,
    "location_id": 1,
    "type": 0,
    "day": 4,
    "day_special": null,
    "day_special_date": null,
    "open": "03:35",
    "close": "18:31",
    "is_open": true
}
```

#### Error status codes
- `404` - Location not found, Opening hour not found

---

### Create location opening hour
```
POST /api/v1/locations/:id/hours
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
The created opening hour.

```json
{
    "type": 0,
    "day": 0,
    "open": "10:00",
    "close": "20:00",
    "is_open": true,
    "location_id": 1,
    "id": 28
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Location not found
- `422` - Response data validation error

---

### Update location opening hour
```
PUT /api/v1/locations/:id/hours/:id
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
- `404` - Location not found, opening hour not found
- `422` - Response data validation error

---

### Delete an opening hour
```
DELETE /api/v1/locations/:id/hours/:id
```

#### Authentication scopes
- `admin`

#### Parameters
None

#### Success response
None

#### Error status codes
- `401` - Authorization error
- `404` - Location not found, opening hour not found

---

### Fetch all menus
```
GET /api/v1/locations/:id/menus
```

#### Authentication scopes
None

#### Parameters
None

#### Success response
A list of all menus for the location along with the items on the menu.
An empty array will be returned if no menus are available.

```json
[
    {
        "id": 1,
        "oid": 400,
        "location_id": 1,
        "name": "new menu",
        "hidden": false,
        "items": [
            {
                "id": 1,
                "menu_id": 1,
                "name": "Tasty Steel Bike",
                "description": "Boston's most advanced compression wear...",
                "price": 759,
                "cover_img_src": "http://placeimg.com/640/480/food",
                "hidden": false,
                "created_at": "2021-04-07T16:11:56.000+02:00",
                "updated_at": "2021-04-07T16:11:56.000+02:00"
            },
            {
                "id": 2,
                "menu_id": 1,
                "name": "Rustic Rubber Chips",
                "description": "The automobile layout consists of a front-engine...",
                "price": 702,
                "cover_img_src": "http://placeimg.com/640/480/food",
                "hidden": false,
                "created_at": "2021-04-07T16:11:56.000+02:00",
                "updated_at": "2021-04-07T16:11:56.000+02:00"
            },
            {
                "id": 3,
                "menu_id": 1,
                "name": "Incredible Metal Ball",
                "description": "The Football Is Good For Training And Recreational...",
                "price": 281,
                "cover_img_src": "http://placeimg.com/640/480/food",
                "hidden": false,
                "created_at": "2021-04-07T16:11:56.000+02:00",
                "updated_at": "2021-04-07T16:11:56.000+02:00"
            }
        ]
    }
]
```

#### Error status codes
- `404` - Location not found

---

### Fetch a single menu
```
GET /api/v1/locations/:id/menus/:id
```

#### Authentication scopes
None

#### Parameters
None

#### Success response
A single nation and its data.

```json
{
    "id": 1,
    "oid": 400,
    "location_id": 1,
    "name": "new menu",
    "hidden": false,
    "items": [
        {
            "id": 1,
            "menu_id": 1,
            "name": "Tasty Steel Bike",
            "description": "Boston's most advanced compression wear...",
            "price": 759,
            "cover_img_src": "http://placeimg.com/640/480/food",
            "hidden": false,
            "created_at": "2021-04-07T16:11:56.000+02:00",
            "updated_at": "2021-04-07T16:11:56.000+02:00"
        },
        {
            "id": 2,
            "menu_id": 1,
            "name": "Rustic Rubber Chips",
            "description": "The automobile layout consists of a front-engine...",
            "price": 702,
            "cover_img_src": "http://placeimg.com/640/480/food",
            "hidden": false,
            "created_at": "2021-04-07T16:11:56.000+02:00",
            "updated_at": "2021-04-07T16:11:56.000+02:00"
        },
        {
            "id": 3,
            "menu_id": 1,
            "name": "Incredible Metal Ball",
            "description": "The Football Is Good For Training And Recreational...",
            "price": 281,
            "cover_img_src": "http://placeimg.com/640/480/food",
            "hidden": false,
            "created_at": "2021-04-07T16:11:56.000+02:00",
            "updated_at": "2021-04-07T16:11:56.000+02:00"
        }
    ]
}
```

#### Error status codes
- `404` - Location not found, Menu not found

---

### Create menu
```
POST /api/v1/locations/:id/menus
```

#### Authentication scopes
- `admin`

#### Parameters
- `name` - string, required
- `hidden` - boolean, required

#### Success response
The created opening hour.

```json
{
    "name": "new menu",
    "hidden": false
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Location not found
- `422` - Response data validation error

---

### Update menu
```
PUT /api/v1/locations/:id/menus/:id
```

#### Authentication scopes
- `admin`

#### Parameters
The request data can contain the following parameters:

- `name` - string
- `hidden` - boolean

#### Success response
The opening hour containing the updated data.

```json
{
    "id": 1,
    "oid": 400,
    "location_id": 1,
    "name": "new menu",
    "hidden": false
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Location not found, menu not found
- `422` - Response data validation error

---

### Delete menu
```
DELETE /api/v1/locations/:id/menus/:id
```

#### Authentication scopes
- `admin`

#### Parameters
None

#### Success response
None

#### Error status codes
- `401` - Authorization error
- `404` - Location not found, menu hour not found

---

### Fetch all menu items
```
GET /api/v1/menus/:id/items
```

#### Authentication scopes
None

#### Parameters
None

#### Success response
A list of all menu items for the menu.
An empty array will be returned if no menu items are available.

```json
[
    {
        "id": 1,
        "menu_id": 1,
        "name": "Ergonomic Soft Sausages",
        "description": "New range of formal shirts are designed keeping you in mind...",
        "price": 492,
        "cover_img_src": "http:/0.0.0.0:3333/http:/placeimg.com/640/480/food",
        "hidden": false,
        "created_at": "2021-04-08T15:23:50.000+02:00",
        "updated_at": "2021-04-08T15:23:50.000+02:00"
    },
    {
        "id": 2,
        "menu_id": 1,
        "name": "Handmade Frozen Pizza",
        "description": "The automobile layout consists of a front-engine design, with...",
        "price": 657,
        "cover_img_src": "http:/0.0.0.0:3333/http:/placeimg.com/640/480/food",
        "hidden": false,
        "created_at": "2021-04-08T15:23:50.000+02:00",
        "updated_at": "2021-04-08T15:23:50.000+02:00"
    },
    {
        "id": 3,
        "menu_id": 1,
        "name": "Fantastic Steel Chicken",
        "description": "The beautiful range of Apple Naturalé that has an exciting mix...",
        "price": 874,
        "cover_img_src": "http:/0.0.0.0:3333/http:/placeimg.com/640/480/food",
        "hidden": false,
        "created_at": "2021-04-08T15:23:50.000+02:00",
        "updated_at": "2021-04-08T15:23:50.000+02:00"
    }
]
```

#### Error status codes
- `404` - Menu not found

---

### Fetch a single menu item
```
GET /api/v1/menus/:id/items/:id
```

#### Authentication scopes
None

#### Parameters
None

#### Success response
A single nation and its data.

```json
{
    "id": 3,
    "menu_id": 1,
    "name": "Fantastic Steel Chicken",
    "description": "The beautiful range of Apple Naturalé that has an exciting mix...",
    "price": 874,
    "cover_img_src": "http:/0.0.0.0:3333/http:/placeimg.com/640/480/food",
    "hidden": false,
    "created_at": "2021-04-08T15:23:50.000+02:00",
    "updated_at": "2021-04-08T15:23:50.000+02:00"
}
```

#### Error status codes
- `404` - Menu not found, Menu item not found

---

### Create menu item
```
POST /api/v1/menus/:id/items
```

#### Authentication scopes
- `admin`

#### Parameters
- `name` - string, required
- `description` - string, required
- `price` - unsigned number, required
- `hidden` - boolean, required

#### Success response
The created menu item.

```json
{
    "id": 82,
    "name": "name",
    "description": "description",
    "price": 100,
    "hidden": false,
    "menu_id": 1,
    "created_at": "2021-04-08T15:32:48.059+02:00",
    "updated_at": "2021-04-08T15:32:48.059+02:00"
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Menu not found
- `422` - Response data validation error

---

### Update menu item
```
PUT /api/v1/menus/:id/items/:id
```

#### Authentication scopes
- `admin`

#### Parameters
The request data can contain the following parameters:

- `name` - string
- `description` - string
- `price` - unsigned number
- `hidden` - boolean

#### Success response
The menu item containing the updated data.

```json
{
    "id": 1,
    "menu_id": 1,
    "name": "new name",
    "description": "new description",
    "price": 300,
    "cover_img_src": "http:/0.0.0.0:3333/http:/placeimg.com/640/480/food",
    "hidden": false,
    "created_at": "2021-04-08T15:23:50.000+02:00",
    "updated_at": "2021-04-08T15:33:50.131+02:00"
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Menu not found, Menu item not found
- `422` - Response data validation error

---

### Delete menu item
```
DELETE /api/v1/menus/:id/items/:id
```

#### Authentication scopes
- `admin`

#### Parameters
None

#### Success response
None

#### Error status codes
- `401` - Authorization error
- `404` - Menu not found, Menu item hour not found

---

### Upload menu item cover image
```
POST /api/v1/menus/:id/items/:id/upload
```

#### Authentication scopes
- `admin`

#### Parameters
- `cover` - cover image (binary)

#### Success response
The updated menu item with the uploaded cover image.

```json
{
    "id": 1,
    "menu_id": 1,
    "name": "new name",
    "description": "new description",
    "price": 300,
    "cover_img_src": "http:/0.0.0.0:3333/8feec6d458664e1fda4e0a00a8832e899b4da5ab.jpg",
    "hidden": false,
    "created_at": "2021-04-08T15:23:50.000+02:00",
    "updated_at": "2021-04-08T15:36:51.435+02:00"
}
```

#### Error status codes
- `401` - Authorization error
- `404` - Menu not found, Menu item not found
- `500` - Image could not be uploaded
