# SPDX-FileCopyrightText: 2024 Dusk Banks <me@bb010g.com>
# SPDX-License-Identifier: ISC
finalArgs: prevArgs:

let
  inherit (finalLib.attrsets)
    attrNames
    listToAttrs
    mapAttrs
    mapAttrsToList
    zipAttrsWith
    ;
  inherit (finalLib.filesystem)
    dirToDirectory
    readDir
    readDirectory
    readShardedDirectory
    ;
  inherit (finalLib.lists)
    concatMap
    head
    length
    ;
  inherit (finalLib.path)
    dirOf
    ;
  inherit (finalLib.strings)
    concatMapStringsSep
    escapeNixIdentifier
    match
    toString
    ;
  inherit (finalLib.trivial)
    isFunction
    isNull
    ;

  finalLib = finalArgs.lib;

  lib.filesystem.dirToDirectory =
    path: dir:
    mapAttrs (name: type: {
      inherit type;
      path = path + "/${name}";
    }) dir;

  lib.filesystem.dirEntryToDirectoryEntry = path: type: { inherit path type; };

  lib.filesystem.readDir = prevFilesystem.readDir or builtins.readDir;

  lib.filesystem.readDirectory = path: dirToDirectory path (readDir path);

  lib.filesystem.readShardedDirectory =
    path:
    let
      getDirectorySingleton =
        name: directories:
        let
          directoryCount = length directories;
        in
        if directoryCount > 1 then
          throw "lib.filesystem.readShardedDirectory: expected at most 1 shard directory to contain a directory named `${escapeNixIdentifier name}` but found ${toString directoryCount} shard directories:\n${
            concatMapStringsSep "\n" (directory: "- ${dirOf (toString directory.path)}") directories
          }"
        else
          head directories;
      shardsDir = readDir path;
      shardDirectories = mapAttrsToList (
        shardName: shardType:
        if shardType == "directory" then readDirectory (path + "/${shardName}") else { }
      ) shardsDir;
    in
    zipAttrsWith getDirectorySingleton shardDirectories;

  lib.filesystem.readNameBasedTableDirectory =
    config:
    let
      columns =
        specialColumns
        // zipAttrsWith (columnName: column: specialColumns.${columnName} or { } // listToAttrs column) (
          mapAttrsToList (
            rowName: row:
            mapAttrs (columnName: cell: {
              name = rowName;
              value = cell;
            }) row
          ) normalRows
        );
      rawSpecialColumns = config.specialColumns or { };
      rawSpecialRows = config.specialRows or { };
      rowFromFile =
        let
          configRowFromFile = if isNull config.rowFromFile or null then { } else config.rowFromFile;
        in
        if isFunction configRowFromFile then
          configRowFromFile
        else
          args@{ fileName, ... }:
          if configRowFromFile ? ${fileName} then
            configRowFromFile.${fileName} args
          else
            throw "lib.filesystem.readNameBasedTableDirectory: function `config.rowFromFile.${escapeNixIdentifier fileName}` missing";
      readRowDirectory = rowName: rowDirectoryEntry: readDirectory rowDirectoryEntry.path;
      readRowsDirectory =
        if isNull config.readRowsDirectory or null then readShardedDirectory else config.readRowsDirectory;
      rowDirectories = mapAttrs readRowDirectory rowsDirectory;
      rowDirectoryToRow =
        rowName: rowDirectory:
        let
          getCellSingleton =
            columnName: cells:
            let
              cellCount = length cells;
            in
            if cellCount > 1 then
              throw "lib.filesystem.readNameBasedTableDirectory: in row `${escapeNixIdentifier rowName}`, expected at most 1 cell for column `${escapeNixIdentifier columnName}` but found ${toString cellCount} cells:\n${
                concatMapStringsSep "\n" (cell: "- ${toString cell.path}") cells
              }"
            else
              (head cells).cell;
          fileNameToRow =
            fileName:
            let
              directoryEntry = rowDirectory.${fileName};
              row' =
                mapAttrs
                  (columnName: cell: {
                    inherit (directoryEntry) path;
                    inherit cell;
                  })
                  (rowFromFile {
                    inherit
                      columns
                      specialColumns
                      directoryEntry
                      fileName
                      normalRow
                      row
                      rowDirectories
                      rowDirectory
                      rowName
                      rows
                      specialRow
                      specialRows
                      ;
                  });
            in
            if isNull (match "_.*" fileName) then [ row' ] else [ ];
          normalRow = zipAttrsWith getCellSingleton (concatMap fileNameToRow (attrNames rowDirectory));
          row = specialRow // normalRow;
          specialRow = specialRows.${rowName} or { };
        in
        row;
      normalRows = mapAttrs rowDirectoryToRow rowDirectories;
      rows = specialRows // normalRows;
      specialColumns =
        rawSpecialColumns
        // zipAttrsWith (columnName: column: rawSpecialColumns.${columnName} or { } // listToAttrs column) (
          mapAttrsToList (
            rowName: row:
            mapAttrs (columnName: cell: {
              name = rowName;
              value = cell;
            }) row
          ) rawSpecialRows
        );
      specialRows =
        rawSpecialRows
        // zipAttrsWith (rowName: row: rawSpecialRows.${rowName} or { } // listToAttrs row) (
          mapAttrsToList (
            columnName: column:
            mapAttrs (rowName: cell: {
              name = columnName;
              value = cell;
            }) column
          ) rawSpecialColumns
        );
      rowsDirectory = readRowsDirectory rowsPath;
      rowsPath =
        config.rowsPath or (throw "lib.filesystem.readNameBasedTableDirectory: expected `config.rowsPath`");
    in
    {
      inherit columns rows;
      inherit specialColumns specialRows;
    };

  prevFilesystem = prevLib.filesystem;
  prevLib = prevArgs.lib;
in
lib.filesystem
