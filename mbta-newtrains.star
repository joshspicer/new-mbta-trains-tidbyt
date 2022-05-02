load("render.star", "render")
load("http.star", "http")
# load("encoding/base64.star", "base64")
# load("cache.star", "cache")

STATION_NAMES_URL  = "https://traintracker.transitmatters.org/stops/Green-B,Green-C,Green-D,Green-E,Orange,Red-A,Red-B"
TRAIN_LOCATION_URL = "https://traintracker.transitmatters.org/trains/Green-B,Green-C,Green-D,Green-E,Orange,Red-A,Red-B"

ARROW_DOWN="⇩"
ARROW_UP="⇧"

def fetchStationNames():
    res = http.get(STATION_NAMES_URL)
    if res.status_code != 200:
        fail("stations request failed with status %d", res.status_code)
    
    stations = res.json()
    map = {}
    for station in stations:
        map[station["id"]] = station["name"]

    return map

def mapStationIdToName(id):
    stations = fetchStationNames()
    return stations[id]

def mapRouteToColor(route):
    if "Red" in route:
        return "#FF0000"
    elif "Green" in route:
        return "#00FF00"
    elif "Orange" in route:
        return "#FFA500"
    else:
        return "#0ff"

def createTrain(loc):
    if loc['direction'] == 1:
        arrow = ARROW_UP
    else:
        arrow = ARROW_DOWN
    
    stationName = mapStationIdToName(loc["stationId"])
    color = mapRouteToColor(loc["route"])

    return render.Row(
                children=[
                    render.Text(
                        content="{} ".format(arrow),
                        color=color
                    ),
                    render.Marquee(
                        child=render.WrappedText(
                            content=stationName,
                            width=56,
                            color=color
                        ),
                        width=64
                    )
                ]
            )

def main():
    res = http.get(TRAIN_LOCATION_URL)
    if res.status_code != 200:
        fail("location request failed with status %d", res.status_code)
        
    apiResult = res.json()

    trains = []
    for loc in apiResult:
        trains.append(createTrain(loc))

    if len(trains) == 0:
        return render.Root(
            child = render.Box(
                child=render.WrappedText(
                        content="No New Trains Running!",
                        width=60
                    )
            )
        )

    return render.Root(
      child = render.Marquee(
            child=render.Column(
                children=trains
            ),
            scroll_direction="vertical",
            height=32
        )
    )