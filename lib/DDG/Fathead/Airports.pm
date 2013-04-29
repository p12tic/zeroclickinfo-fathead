package DDG::Fathead::Airports;

use DDG::Fathead;

primary_example_queries "iata vie";

secondary_example_queries
    "icao jfk",
    "iata jacksonville international airport";

description "IATA/ICAO Airport codes";

name "Airports";

icon_url "";

source "Wikipedia";

code_url "https://github.com/duckduckgo/zeroclickinfo-fathead/tree/master/share/airports";

topics "special_interest";

category "ids";

attribution
    github => ['https://github.com/mellon85', 'mellon85'];

1;
