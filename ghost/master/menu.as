/*
	メニュー関係。
*/

talk MainMenu {
	\0
	\![*]\q[耳をすます,OnMenuRandomTalk]
	\![*]\q[間隔変更,OnChagneTalkInterval]
	
	\![*]\q[閉じる,OnMenuClose]
}

function OnMenuRandomTalk {
	local script = OnRandomTalk()();
	if(script.length>0){
		return script;
	}
	return Reflection.Get("ランダムトーク")();
}

talk OnMenuClose {
	\e
}


/*
	喋り間隔の設定
*/

talk OnChagneTalkInterval {
	\0
	{TalkIntervalItem(60, "１分")}
	{TalkIntervalItem(120, "２分")}
	{TalkIntervalItem(180, "３分")}
	{TalkIntervalItem(0, "何も聞こえない")}

	\![*]\q[戻る,MainMenu]
	\![*]\q[閉じる,OnMenuClose]
}

function TalkIntervalItem(seconds, label) {
	local item = "\![*]\q[{label},OnSetTalkInterval,{seconds}]";
	if(seconds == Save.Data.TalkInterval){
		item = item + "←";
	}
	return item;
}

function OnSetTalkInterval {
	local interval = Shiori.Reference[0];
	SetTalkInterval(interval);
	return OnChagneTalkInterval();
}

