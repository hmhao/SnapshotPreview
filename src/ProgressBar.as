package {
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import com.greensock.TweenLite;
	
	/**
	 * ...
	 * @author hmh
	 */
	public class ProgressBar extends Sprite {
		// 移动方向
		public static const DIRECTION_NONE:int = 0;
		public static const DIRECTION_LEFT:int = -1;
		public static const DIRECTION_RIGHT:int = 1;
		// 快照卡大小
		public static const cardWidth:int = 120;
		public static const cardHeight:int = 70;
		
		protected var direction:int = DIRECTION_NONE;
		protected var parentWidth:Number;
		protected var thisWidth:Number;
		protected var cardLen:int;//图片墙的图片个数
		protected var cardArr:Vector.<Card>;//图片墙的图片数组
		protected var curIndex:int;//当前鼠标所指位置高亮的图片块索引
		protected var offsetIndex:int;//鼠标所指位置的图片块在图片墙中的偏移位置
		protected var _bar:Sprite;
		protected var preview:Sprite;
		protected var border:Shape;
		protected var loader:Loader;
		
		public function ProgressBar(width:Number) {
			parentWidth = width;
			thisWidth = width;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			this.initBar();
			this.initCard();
			this.initBorder();
		}
		
		protected function initBar():void {
			_bar = new Sprite();
			_bar.graphics.beginFill(0x999999);
			_bar.graphics.drawRect(0, 0, thisWidth, 5);
			_bar.graphics.endFill();
			this.addChild(_bar);
		}
		
		protected function initCard():void {
			// 补3块使运动不缺缝隙
			cardLen = Math.floor(parentWidth / cardWidth) + 3;
			cardArr = new Vector.<Card>();
			preview = new Sprite();
			var card:Card;
			// 将第1块排列在左侧外
			for (var i:int = 0; i < cardLen; i++) {
				card = new Card(cardWidth, cardHeight, i);
				card.x = (i - 1) * cardWidth;
				card.y = 0;
				cardArr.push(card);
				preview.addChild(card);
			}
			preview.y = -cardHeight - 10;
			addChild(preview);
		}
		
		protected function initBorder():void {
			border = new Shape();
			border.graphics.beginFill(0x00BFFF);
			border.graphics.drawRect(0, 0, cardWidth, cardHeight);
			border.graphics.drawRect(5, 5, cardWidth - 10, cardHeight - 10);
			border.graphics.endFill();
			border.y = preview.y;
			this.addChild(border);
		}
		
		public function init(imagePath:String):void {
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.renderImage);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.renderImage);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.renderImage);
			loader.load(new URLRequest(imagePath));
		}
		
		public function showImage(curTime:Number):void {
			curTime = Math.round(curTime);
			var index:int = this.getIndexFormTime(curTime);
			if (index == this.curIndex) {// 微小的移动不做处理
				return;
			}
			//var mouseOffsetParent:Point = this.localToGlobal(new Point(this.mouseX, this.mouseY));
			var offset:Number = this.mouseX;
			var offsetIndex:int = this.getOffsetIndex(offset);
			if (offsetIndex <= 1) {// 边框固定在左侧
				preview.x = 0;
				border.x = 0;
			} else if (offsetIndex > cardLen + 2) {// 边框固定在右侧
				preview.x = thisWidth - (cardLen - 2) * cardWidth;
				border.x = thisWidth - cardWidth;
			} else {
				//对正中间
				var offsetX:Number = offsetIndex * 60;
				if (offsetX != 0 && offsetIndex % 2 == 0) {
					offsetX += 60;
				}
				preview.x = offset - offsetX;
				border.x = offset - 60;
			}
			var minu:int = Math.floor(curTime / 60);
			var second:int = Math.floor(curTime % 60);
			trace("时间:"+curTime, minu+"分", second+"秒", "第"+index+"个", "偏移:"+offsetIndex, "鼠标X"+this.mouseX, cardLen);
			if (index > this.curIndex) {
				this.direction = DIRECTION_RIGHT;
			} else if (index < this.curIndex) {
				this.direction = DIRECTION_LEFT;
			} else {
				this.direction = DIRECTION_NONE;
			}
			this.curIndex = index;
			this.offsetIndex = offsetIndex;
			this.imageMotion();
			this.renderImage();
			cardArr[Math.floor(offsetIndex / 2) + 1].isHighlight = true;//高亮鼠标所指图片块
		}
		
		protected function imageMotion():void {
			var card:Card;
			var i:int = 0, len:int = 0;
			for (i = 0, len = this.cardArr.length; i < len; i++) {// 各块复位
				card = this.cardArr[i];
				TweenLite.killTweensOf(card);
				card.x = cardWidth * (i - 1);
			}
			if(this.direction == DIRECTION_RIGHT){
				this.cardArr.push(this.cardArr.shift());// 右移时,将第一块加入队列后,逻辑上
			}else if (this.direction == DIRECTION_LEFT) {
				this.cardArr.unshift(this.cardArr.pop());// 左移时,将最后一块加入队列前,逻辑上
			}
			for (i = 0, len = this.cardArr.length; i < len; i++) {
				card = this.cardArr[i];
				/* 根据上面左右移动的调整，这里相当于:
				 * 左移时,将最后一块移动到最前面,其余块往后移动,物理上
				 * 右移时,将第一块移动到最后面,其余块往前移动,物理上
				 */
				if ((i == 0 && this.direction == DIRECTION_LEFT)|| (i == (len-1) && this.direction == DIRECTION_RIGHT)) {
				   card.x = cardWidth * (i - 1);
				}
				TweenLite.to(card, 0.5, {x: cardWidth * (i - 1)});
			}
		}
		
		protected function renderImage(evt:Event = null):void {
			var card:Card;
			var position:Object;
			var i:int, j:int;
			var isLoaded:Boolean = loader.content ? true : false;
			var center:int = Math.floor(this.offsetIndex / 2) + 1;
			for (i = 0; i < this.cardArr.length; i++) {
				card = this.cardArr[i];//图片墙中第i个图片块
				card.setLoading();
				card.isHighlight = false;
				if(isLoaded){
					j = this.curIndex + (i - center);//以鼠标所指图片块为基准,往前往后更新图片
					position = this.getPosition(j);//计算第j张图片在资源文件中的位置
					this.updateCard(position, card, j);//用第j张图片来更新第i个图片块
				}
			}
		}
		/**
		 * 更新图片块的数据
		 * @param	position	图片数据所在资源图片中的位置
		 * @param	card		需要更新的图片块
		 * @param	index
		 */
		protected function updateCard(position:Object, card:Card, index:int):void {
			card.setTime((index + 1) * 5);//计算并设置图片时间
			var content:DisplayObject;
			var matrix:Matrix;
			try {
				content = loader.content as DisplayObject;
				matrix = new Matrix(1, 0, 0, 1, (-cardWidth) * position.x, (-cardHeight) * position.y);
				card.bitmapData.draw(content, matrix);//更新图片数据
			} catch (error:Error) {
			}
		}
		/**
		 * 计算该索引对应资源图片中的行列位置
		 * @param	index
		 * @return	{x, y}
		 */
		protected function getPosition(index:int):Object {
			index = Math.max(0, Math.min(index, 100));
			var _x:Number = Math.floor(index % 100 % 10);
			var _y:Number = Math.floor(index % 100 / 10);
			return {x: _x, y: _y};
		}
		/**
		 * 计算该时间对应资源图片中的图片索引
		 * @param	curTime
		 * @return	index
		 */
		protected function getIndexFormTime(curTime:Number):int {
			// 取其开闭区间:第0张图 (0-5], 第1张图 (5,10] ...以此类推
			return Math.ceil(curTime / 5) - 1;
		}
		/**
		 * 计算该偏移量对应图片墙中的偏移索引
		 * @param	offset
		 * @return	index
		 */
		protected function getOffsetIndex(offset:Number):int {
			var index:int = offset / (cardWidth / 2) + 1;
			return index;
		}
		
		override public function get height():Number {
			return cardHeight;
		}
		
		override public function get width():Number {
			return thisWidth;
		}
		
		public function get bar():Sprite {
			return _bar;
		}
	}

}