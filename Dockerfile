FROM haxe:4.3.4 AS build

COPY . .
RUN haxelib install js.hxml --always
RUN haxelib git deepnightLibs https://github.com/deepnight/deepnightLibs
RUN haxe js.hxml

FROM httpd:2.4 AS deploy

COPY --from=build index.html htdocs/
COPY --from=build bin/client.js htdocs/bin/
