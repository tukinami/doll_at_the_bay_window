

//デフォルトセーブデータ
function OnAosoraDefaultSaveData {
	Save.Data.TalkInterval = 120;
	Save.Data.DefaultSurface = 0;
	Save.Data.BirdExists = false;
	Save.Data.LetterExists = false;
	Save.Data.BackgroundCount = 0;
}

//SHIORIロード後
function OnAosoraLoad {
	//ランダムトークの設定
	TalkTimer.RandomTalk = OnRandomTalk;
	TalkTimer.RandomTalkIntervalSeconds = Save.Data.TalkInterval;

	//なでられトークの設定
	TalkTimer.NadenadeTalk = Reflection.Get("OnNadenade");
}

//喋り間隔の設定
function SetTalkInterval(intervalSeconds){
	//間隔を設定して、待ち時間をリセット
	TalkTimer.RandomTalkIntervalSeconds = intervalSeconds;
	TalkTimer.RandomTalkElapsedSeconds = 0;
	Save.Data.TalkInterval = intervalSeconds;
}

//選択肢
function OnChoiceSelect{
	return Reflection.Get(Shiori.Reference[0]);
}

function OnBoot {
	backgroundSetCount(Save.Data.BackgroundCount);

	local script = "\0{SurfaceRestore}\1\s[10]\_w[10]";
	script += "\1\![set,alignmenttodesktop,free]\_w[10]\![move,--X=0,--Y=-0,--time=0,--base=0,--base-offset=right.bottom,--move-offset=right.bottom,--option=ignore-sticky-window]\_w[10]\![set,sticky-window,1,0]";
	return script + 起動();
}

function OnClose() {
	Save.Data.BackgroundCount = backgroundCount();
	//少しウェイトをいれてやる
	return OnDisplayBirdExitOnClose() + 終了時トーク() + "\w9\w9\w9";
}

talk 終了時トーク {
	>終了
}

//通常の表情にもどす
talk OnSurfaceRestore {
	{SurfaceRestore}
}

function SurfaceRestore {
	return "\s[{現在のサーフェス}]";
}

/*
	触り反応
*/
local collisions = {
	letter: "手紙"
};
		
talk OnMouseDoubleClick {
	%{
		local colName = collisions[Shiori.Reference[4]];
	}
	>MainMenu : Shiori.Reference[4] == ""
	>Reflection.Get(colName + "つつかれ")
}

talk OnNadenade {
	%{
		local colName = collisions[Shiori.Reference[4]];
	}
	>Reflection.Get(colName + "なでられ")
}

/*
	基本単語
*/

function 現在のサーフェス {
	return Save.Data.DefaultSurface;
}