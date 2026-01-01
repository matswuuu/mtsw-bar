{
  description = "A customizable Quickshell bar";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, quickshell, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      quickshell = quickshell;
      qt6 = pkgs.qt6;
      qtPackages = {
        qt3d = pkgs.qt6.qt3d;
        qt5compat = pkgs.qt6.qt5compat;
        qtcharts = pkgs.qt6.qtcharts;
        qtconnectivity = pkgs.qt6.qtconnectivity;
        qtdatavis3d = pkgs.qt6.qtdatavis3d;
        qtdeclarative = pkgs.qt6.qtdeclarative;
        qtdoc = pkgs.qt6.qtdoc;
        qtgraphs = pkgs.qt6.qtgraphs;
        qtgrpc = pkgs.qt6.qtgrpc;
        qthttpserver = pkgs.qt6.qthttpserver;
        qtimageformats = pkgs.qt6.qtimageformats;
        qtlanguageserver = pkgs.qt6.qtlanguageserver;
        qtlocation = pkgs.qt6.qtlocation;
        qtlottie = pkgs.qt6.qtlottie;
        qtmultimedia = pkgs.qt6.qtmultimedia;
        qtmqtt = pkgs.qt6.qtmqtt;
        qtnetworkauth = pkgs.qt6.qtnetworkauth;
        qtpositioning = pkgs.qt6.qtpositioning;
        qtsensors = pkgs.qt6.qtsensors;
        qtserialbus = pkgs.qt6.qtserialbus;
        qtserialport = pkgs.qt6.qtserialport;
        qtshadertools = pkgs.qt6.qtshadertools;
        qtspeech = pkgs.qt6.qtspeech;
        qtquick3d = pkgs.qt6.qtquick3d;
        qtquick3dphysics = pkgs.qt6.qtquick3dphysics;
        qtquickeffectmaker = pkgs.qt6.qtquickeffectmaker;
        qtquicktimeline = pkgs.qt6.qtquicktimeline;
        qtremoteobjects = pkgs.qt6.qtremoteobjects;
        qtsvg = pkgs.qt6.qtsvg;
        qtscxml = pkgs.qt6.qtscxml;
        qttools = pkgs.qt6.qttools;
        qttranslations = pkgs.qt6.qttranslations;
        qtvirtualkeyboard = pkgs.qt6.qtvirtualkeyboard;
        qtwebchannel = pkgs.qt6.qtwebchannel;
        qtwebengine = pkgs.qt6.qtwebengine;
        qtwebsockets = pkgs.qt6.qtwebsockets;
        qtwebview = pkgs.qt6.qtwebview;
      };

      nixosModules.mtsw-bar = import ./module.nix;
    };
}
