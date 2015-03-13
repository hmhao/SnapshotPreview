package  {
	
	/**
	 * 格式化工具类
	 * @author hmh&&lsl
	 */
	public class Format {
		
		public static function timeToNumber(str:String):Number {
			var timeArr:Array = str.split(':');
			if (timeArr.length == 0) {
				return Number(str);
			}
			var num:int = 0;
			var index:Number = 60;
			var len:Number = timeArr.length;
			for (var i:*in timeArr) {
				num += timeArr[i] * Math.pow(index, len - 1 - i);
			}
			return num;
		}
		
		public static function numberToTime(s:Number):String {
			s = Math.floor(s);
			var m:Number = 0;
			var h:Number = 0;
			if (isNaN(s)) {
				s = 0;
			}
			if (s / 3600 >= 1) {
				h = Math.floor(s / 3600);
				s -= h * 3600;
			}
			if (s / 60 >= 1) {
				m = Math.floor(s / 60);
				s -= m * 60;
			}
			return (h < 10 ? '0' + h : h) + ':' + (m < 10 ? '0' + m : m) + ':' + (s < 10 ? '0' + s : s);
		}
	
	}

}