package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author hmh
	 */
	public class Main extends Sprite {
		private var _width:Number;
		private var controlBar:ControlBar;
		private var progressBar:ProgressBar;
		private var time:Timer;
		
		public function Main():void {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			_width = stage.stageWidth - 2 * ProgressBar.cardWidth + 61;
			controlBar = new ControlBar(_width);
			progressBar = new ShortProgressBar(_width);
			controlBar.addChild(progressBar);
			addChild(controlBar);
			
			controlBar.x = ProgressBar.cardWidth;
			controlBar.y = stage.stageHeight - controlBar.height;
			
			progressBar.x = 75;//for ShortProgressBar
			progressBar.y = 10;
			progressBar.init('http://vod.kankan.com/v/thumbnail/70/70234/293096/aeeec94c7a517e3c1e3213e346fa1c81_30_0.jpg');
			
			progressBar.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			time = new Timer(500);
			time.addEventListener(TimerEvent.TIMER, onTimer);
			//time.start();
		}
		
		private function onMouseMove(evt:MouseEvent):void {
			if (evt.target == progressBar.bar) {
				var totalTime:Number = 500;
				var offset:Point = progressBar.globalToLocal(new Point(this.mouseX, this.mouseY));
				var curTime:Number = offset.x / progressBar.width * totalTime;
				progressBar.showImage(curTime);
			}
		}
		
		private function onTimer(evt:TimerEvent):void {
			progressBar.showImage(time.currentCount);
		}
	}
}