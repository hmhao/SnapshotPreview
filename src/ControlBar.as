package {
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author hmh
	 */
	public class ControlBar extends Sprite {
		
		public function ControlBar(width:Number) {
			this.graphics.beginFill(0x333333);
			this.graphics.drawRect(0, 0, width, 45);
			this.graphics.endFill();
		}
	
	}

}