import { dest, src } from "gulp";
import texturePacker from "gulp-free-tex-packer";

export default () =>
  src("art/export/**/*", { encoding: false })
    .pipe(
      texturePacker({
        textureName: "gameElements",
        allowRotation: false,
        allowTrim: false,
        removeFileExtension: true,
        packer: "OptimalPacker",
        exporter: "Spine",
      })
    )
    .pipe(dest("res/"));
