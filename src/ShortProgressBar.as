package {
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author hmh
	 */
	public class ShortProgressBar extends ProgressBar {
		public static const PG_X:Number = 75;
		public static const PG_R:Number = 15;
		
		public function ShortProgressBar(width:Number) {
			super(width);
			parentWidth = width;
			thisWidth = width - PG_X - PG_R; //进度条长度不等于父容器长度
		}
		override protected function initCard():void {
			cardLen = Math.ceil(parentWidth / cardWidth) + 3;//或者+4
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
		
		override public function showImage(curTime:Number):void {
			curTime = Math.round(curTime);
			var index:int = this.getIndexFormTime(curTime);
			if (index == this.curIndex) { // 微小的移动不做处理
				return;
			}
			var a:int = PG_X;
			var mouseOffsetParentX:Number = this.mouseX + a;
			var offsetIndex:int = this.getOffsetIndex(mouseOffsetParentX);
			var previewX:Number, borderX:Number;
			if (index == 0) { // 边框固定在左侧
				previewX = -PG_X - cardWidth;
				borderX = -PG_X;
			} else if (mouseOffsetParentX > parentWidth - 60) { // 边框固定在右侧
				previewX = thisWidth - offsetIndex * cardWidth + PG_R;
				borderX = thisWidth - cardWidth + PG_R;
			} else {
				//对正中间
				var offsetX:Number = offsetIndex * cardWidth - 60;//(offsetIndex==0 ? 3 : offsetIndex+2)
				previewX = this.mouseX - offsetX;
				borderX = this.mouseX - 60;
			}
			preview.x = previewX;
			if (border.x != borderX)
				TweenLite.to(border, 0.5, {x: borderX});
			var minu:int = Math.floor(curTime / 60);
			var second:int = Math.floor(curTime % 60);
			trace("时间:" + curTime, minu + "分", second + "秒", "第" + index + "个", "偏移:" + offsetIndex, "鼠标X:" + mouseOffsetParentX, cardLen);
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
			cardArr[offsetIndex].isHighlight = true; //高亮鼠标所指图片块
		}
		
		override protected function renderImage(evt:Event = null):void {
			var card:Card;
			var position:Object;
			var i:int, j:int;
			var isLoaded:Boolean = loader.content ? true : false;
			for (i = 0; i < this.cardArr.length; i++) {
				card = this.cardArr[i];//图片墙中第i个图片块
				card.setLoading();
				card.isHighlight = false;
				if(isLoaded){
					j = this.curIndex + (i - offsetIndex);//以鼠标所指图片块为基准,往前往后更新图片
					position = this.getPosition(j);//计算第j张图片在资源文件中的位置
					this.updateCard(position, card, j);//用第j张图片来更新第i个图片块
				}
			}
		}
		
		/**
		 * 计算该偏移量对应图片墙中的偏移索引
		 * @param	offset
		 * @return	index
		 */
		override protected function getOffsetIndex(offset:Number):int {
			var index:int = offset / cardWidth + 2;
			return index;
		}
	}
}