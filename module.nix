{ config, pkgs, lib, quickshell, ... }:
  let
    qt6 = pkgs.qt6Packages;
    kde = pkgs.kdePackages;

    libs = with pkgs; [
      qt6.qt3d
      qt6.qt5compat
      qt6.qtcharts
      qt6.qtconnectivity
      qt6.qtdatavis3d
      qt6.qtdeclarative
      qt6.qtdoc
      qt6.qtgraphs
      qt6.qtgrpc
      qt6.qthttpserver
      qt6.qtimageformats
      qt6.qtlanguageserver
      qt6.qtlocation
      qt6.qtlottie
      qt6.qtmultimedia
      qt6.qtmqtt
      qt6.qtnetworkauth
      qt6.qtpositioning
      qt6.qtsensors
      qt6.qtserialbus
      qt6.qtserialport
      qt6.qtshadertools
      qt6.qtspeech
      qt6.qtquick3d
      qt6.qtquick3dphysics
      qt6.qtquickeffectmaker
      qt6.qtquicktimeline
      qt6.qtremoteobjects
      qt6.qtsvg
      qt6.qtscxml
      qt6.qttools
      qt6.qttranslations
      qt6.qtvirtualkeyboard
      qt6.qtwebchannel
      qt6.qtwebengine
      qt6.qtwebsockets
      qt6.qtwebview
    ];

    qmlPath = builtins.concatStringsSep ":" (map (p: "${p}/lib/qt-6/qml") libs);
    pluginPath = builtins.concatStringsSep ":" (map (p: "${p}/lib/qt-6/plugins") libs);
  in
{
  environment.etc = {
    "xdg/quickshell" = {
      source = ./src;
    };
  };

  environment.systemPackages = [ quickshell.packages.${pkgs.system}.quickshell ] ++ libs;

  systemd.user.services.mtsw-bar = {
    description = "mtsw Quickshell bar";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Restart = "on-failure";
      ExecStart = "${quickshell.packages.${pkgs.system}.quickshell}/bin/quickshell -p /etc/xdg/quickshell/shell.qml";
      Environment = [
        "QML_IMPORT_PATH=${qmlPath}"
        "QT_PLUGIN_PATH=${pluginPath}"
      ];
    };
  };
}
