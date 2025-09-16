# ARMuseumDB
## Collections
- MuseumData
- PanelData
- RoomData
- PanelCuratorLocations
- CommunitySessionData

### MuseumData
- museumID
- roomIDs []
- curators []

### PanelData
- panelID
- museumID
- colourHexCode
- text
- icon

### RoomData
- roomID
- museumID
- referenceImageLocation

### PanelCuratorLocations
- panelID
- roomID
- x
- y
- z

## Endpoints
### Public
- Get museum names
  - /api/museums
  - Return all the names of museums available. These can be presented to the user to ascertain which location they are at
  - 200: List of strings returned
  - 500: Error getting museum names. Server error
- Get room marker images
  - /api/:museumID/markerImages
  - Get all room markers for a specified museumID
  - 200: return images
  - 204: museumID is valid, but there are no marker images in the database
  - 400: museumID not found. Invalid parameter
  - 500: other error
- Post curator panel location
  - Save a set of xyz coordinates alongside a panelID
  - /api/:museumID/:roomID/panels
  - body: { panelID (string), x (number), y (number), z (number) }
  - 201: Panel location saved
  - 400: PanelID not valid / RoomID not valid
  - 500: other error
- Get curator panel locations
  - Get the xyz coordinates, alonside panel data (color, image, text), for all panels in a given room
  - /api/:museumID/:roomID/panels
  - 200: return panel locations
  - 204: roomID and museumID valid, but no panels are saved yet
  - 400: roomID/museumID not found. Invalid parameter
  - 500: other error
- Validate curator login
  - Check if a curatorID and password matches values stored on the database
  - /api/:museumID/login
  - body: { curatorID (string), curatorPassword (string) }
  - 200: Login details are correct
  - 400: Login details are missing from parameters
  - 401: Login details are incorrect
  - 500: Problem checking the database. Dont allow them to proceed, however details may be correct. 

### Private Functions
- Check roomID and museumID valid
  - True: the specified roomID belongs to the specified museumID, and both museumID and roomID exists
  - False: roomID or museumID is invalid
