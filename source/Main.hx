package;

import debug.FPSCounter;
import flixel.FlxGame;
import flixel.FlxG;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
import lime.system.System;
import states.Init;

#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import sys.io.File;
#end

using StringTools;

class Main extends Sprite
{
	var game = {
		width: 1280,
		height: 720,
		initialState: Init,
		zoom: -1.0,
		framerate: 60,
		skipSplash: true,
		startFullscreen: true
	};

	public static var fpsVar:FPSCounter;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		// Diretório seguro (Android / Desktop / CI)
		Sys.setCwd(System.applicationStorageDirectory);

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth = Lib.current.stage.stageWidth;
		var stageHeight = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX = stageWidth / game.width;
			var ratioY = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		addChild(new FlxGame(
			game.width,
			game.height,
			game.initialState,
			game.framerate,
			game.framerate,
			game.skipSplash,
			game.startFullscreen
		));

		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);

		#if mobile
		fpsVar.scaleX = fpsVar.scaleY = 1.5;
		#end

		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(
			UncaughtErrorEvent.UNCAUGHT_ERROR,
			onCrash
		);
		#end
	}

	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg = "";
		var dateNow = Date.now().toString().replace(" ", "_").replace(":", "-");
		var path = "crash_" + dateNow + ".txt";

		for (item in CallStack.exceptionStack(true))
		{
			switch (item)
			{
				case FilePos(_, file, line, _):
					errMsg += file + " (line " + line + ")\n";
				default:
			}
		}

		errMsg += "\nUncaught Error:\n" + e.error;
		File.saveContent(path, errMsg);

		Application.current.window.alert(errMsg, "Crash");
		Sys.exit(1);
	}
	#end
}
