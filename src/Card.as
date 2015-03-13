package {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author hmh
	 */
	public class Card extends Sprite {
		private var _bmpLayer:Sprite;
		private var _bitmapData:BitmapData;
		private var _bitmap:Bitmap;
		private var _stateText:TextField;
		private var _textBg:Sprite;
		private var _time:Number;
		private var _timeTF:TextField;
		private var _txt:TextField;
		
		public function Card(width:Number, height:Number, num:int) {
			this._bmpLayer = new Sprite();
			this.addChild(this._bmpLayer);
			this._bitmapData = new BitmapData(width, height, false, 0);
			this._bitmap = new Bitmap(this._bitmapData);
			this._bitmap.smoothing = true;
			this._bmpLayer.addChild(this._bitmap);
			this._textBg = new Sprite();
			this._textBg.graphics.beginFill(0);
			this._textBg.graphics.drawRect(0, 0, width, height);
			this._textBg.graphics.endFill();
			this._textBg.visible = false;
			addChild(this._textBg);
			this._stateText = new TextField();
			this._stateText.defaultTextFormat = new TextFormat("微软雅黑", 12, 0xFFFFFF);
			this._stateText.autoSize = TextFieldAutoSize.CENTER;
			this._stateText.width = 100;
			this._stateText.height = 20;
			this._stateText.selectable = false;
			this._stateText.x = (width - this._stateText.width) / 2;
			this._stateText.y = (height - this._stateText.height) / 2;
			this._stateText.visible = false;
			addChild(this._stateText);
			var tf:TextFormat = new TextFormat();
			tf.font = "微软雅黑";
			tf.size = 13;
			tf.color = 0xFFFFFF;
			tf.leading = 1;
			tf.align = TextFormatAlign.CENTER;
			this._timeTF = new TextField();
			this._timeTF.defaultTextFormat = tf;
			this._timeTF.selectable = false;
			this._timeTF.multiline = true;
			this._timeTF.wordWrap = true;
			this._timeTF.cacheAsBitmap = true;
			this._timeTF.width = width;
			this._timeTF.height = 20;
			this._timeTF.x = 0;
			this._timeTF.y = -this._timeTF.height + 2;
			this._timeTF.visible = false;
			addChild(this._timeTF);
			//this.addEventListener(MouseEvent.ROLL_OVER, this.onCardRollOver);
			//this.addEventListener(MouseEvent.ROLL_OUT, this.onCardRollOut);
			//this._bmpLayer.addEventListener(MouseEvent.CLICK, this.onCardClick);
			
			this._txt = new TextField();
			this._txt.autoSize = TextFieldAutoSize.CENTER;
			this._txt.width = 100;
			this._txt.height = 20;
			this._txt.defaultTextFormat = tf;
			this._txt.text = "" + num;
			addChild(this._txt);
		}
		
		private function onCardRollOver(event:MouseEvent):void {
			this._bitmap.transform.colorTransform = new ColorTransform(0.65, 0.65, 0.65, 1, 89, 89, 89, 0);
			this._timeTF.visible = true;
		}
		
		private function onCardRollOut(event:MouseEvent):void {
			this._timeTF.visible = false;
			this._bitmap.transform.colorTransform = new ColorTransform();
		}
		
		/*private function onCardClick(event:MouseEvent) : void {
		   var cEvent:CardEvent = new CardEvent(CardEvent.CLICK_SEEK);
		   cEvent.time = this._time;
		   this.dispatchEvent(cEvent);
		 }*/
		
		public function setError():void {
			this._textBg.visible = true;
			this._stateText.visible = true;
			this._stateText.text = "预览加载失败";
		}
		
		public function setLoading():void {
			this._textBg.visible = true;
			this._stateText.visible = true;
			this._stateText.text = "加载中";
		}
		
		public function get bitmapData():BitmapData {
			this._textBg.visible = false;
			this._stateText.visible = false;
			return this._bitmapData;
		}
		
		public function setTime(time:Number):void {
			this._timeTF.text = Format.numberToTime(time);
			this._time = time;
		}
		
		public function set isHighlight(value:Boolean):void {
			value ? onCardRollOver(null) : onCardRollOut(null);
		}
	}
}