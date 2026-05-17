
/*
	ゴースト基本処理
*/

function OnDisplayBirdEntry {
    if(Save.Data.BirdExists){
        return "";
    }
    
    return "\t\i[21100]\![bind,visitor1,bird,1]\![embed,OnDisplayBirdEntryFlag]";
}

function OnDisplayBirdEntryFlag {
    Save.Data.BirdExists = true;
}

function OnDisplayBirdExit {
    if(Save.Data.BirdExists){
        return "\t\![bind,visitor1,bird,0]\i[21200]\![embed,OnDisplayBirdExitFlag]";
    } 
    return "";
}

function OnDisplayBirdExitFlag {
    Save.Data.BirdExists = false;
}

function OnDisplayLetterEntry {
    if(Save.Data.LetterExists){
        return "";
    } 
    return "\t\i[22100,wait]\![bind,visitor2,letter,1]\![embed,OnDisplayLetterEntryFlag]";
}

function OnDisplayLetterEntryFlag {
    Save.Data.LetterExists = true;
}

function OnDisplayLetterExit {
    if(Save.Data.LetterExists){
        return "\t\![bind,visitor2,letter,0]\i[22200]\![embed,OnDisplayLetterExitFlag]";
    }
    return "";
}

function OnDisplayLetterExitFlag {
    Save.Data.LetterExists = false;
}

function OnDisplayBirdExitOnClose {
    birdEvent.InitMember();
    return OnDisplayBirdExit() + "\__w[animation,21200]";
}

function OnDisplaySurfaceChange(currentSurface, nextSurface) {
    return "\t\s[{currentSurface}]\i[10090,wait]\s[{nextSurface}]";
}

/*
    デフォルトサーフェス
*/

function ChangeDefaultSurface {
	local currentSurface = Save.Data.DefaultSurface;
	local nextSurface = (currentSurface + 1) % 4;

	SetDeaultSurface(nextSurface);
	return OnDisplaySurfaceChange(currentSurface, nextSurface);
}

function SetDeaultSurface(surfaceNumber) {
	Save.Data.DefaultSurface = surfaceNumber % 4;
}

/*
    独自イベントの処理
*/

class EventInterval {
    init(interval) {
        this.interval = interval;
        this.count = 0;
    }

    function AddCount {
        this.count += 1;
    }

    function IsOver {
        return this.count >= this.interval;
    }
}

class BirdParameter {
    init {
        this.count = 0;
        this.limit = Random.GetIndex(2, 5);
        this.firstPerson = Random.Select(["私", "俺", "僕", "自分"]);
        this.tone = Random.Select(["粗野", "丁寧", "子供", "若者"]);
    }

    function AddCount {
        this.count += 1;
    }

    function IsEnd {
        return this.count >= this.limit;
    }
}

function birdEventInterval {
    return Random.GetIndex(120, 240);
}

function birdEventEndInterval {
    return Random.GetIndex(30, 55);
}

class BirdEvent {
    init {
        
        this.interval = new EventInterval(birdEventInterval());
        this.parameter = new BirdParameter();
        this.endInterval = new EventInterval(birdEventEndInterval());
    }

    function InitMember {
        this.interval = new EventInterval(birdEventInterval());
        this.parameter = new BirdParameter();
        this.endInterval = new EventInterval(birdEventEndInterval());
    }

    function CheckOnSec {
        if(!this.interval.IsOver()){
            this.interval.AddCount();
            return "";
        }
        else if(!Save.Data.BirdExists){
            return birdEventScriptOnEntry();
        }

        if(this.parameter.IsEnd()||Save.Data.TalkInterval==0){
            this.endInterval.AddCount();

            if(this.endInterval.IsOver()){
                local exit = birdEventScriptOnExit();
                this.InitMember();
                return exit;
            }
        }

        return "";
    }
}

function birdEventScriptOnEntry {
    return OnDisplayBirdEntry()+"\w9\w9"+Reflection.Get("小鳥登場"+birdEvent.parameter.tone)();
}

function birdEventScriptOnExit {
    return Reflection.Get("小鳥退場"+birdEvent.parameter.tone)()+"\w9"+OnDisplayBirdExit();
}

function letterEventInterval {
    return Random.GetIndex(240, 600);
}

class LetterEvent {
    init {
        this.interval = new EventInterval(letterEventInterval());
        this.script = "";
    }

    function InitMember {
        this.interval = new EventInterval(letterEventInterval());
        this.script = "";
    }

    function CheckOnSec {
        if(!this.interval.IsOver()){
            this.interval.AddCount();
            return "";
        }
        else if(this.script.length>0){
            local temp = this.script;
            this.script = "";
            return temp;
        }
        else if(!Save.Data.LetterExists){
            return letterEventScriptOnEntry();
        }

        return "";
    }

    function HandleOnDoubleClick {
        this.InitMember();
    }

    function ShiftTiming(script){
        this.script = script;
        this.interval += Random.GetIndex(5,10);
    }
}

class BackgroundEvent {
    init {
        this.interval = new EventInterval(600);
    }

    function InitMember {
        this.interval = new EventInterval(600);
    }

    function CheckOnSec {
        if(!this.interval.IsOver()){
            this.interval.AddCount();
            return "";
        }
        else {
            this.InitMember();
            return ChangeDefaultSurface();
        }
    }

    function SetCount(count){
        this.interval.count = count;
    }

    function Count {
        return this.interval.count;
    }
}

function letterEventScriptOnEntry {
    return OnDisplayLetterEntry() + "\w9\w9\0\c" + 手紙登場();
}

local birdEvent = new BirdEvent();
local letterEvent = new LetterEvent();
local backgroundEvent = new BackgroundEvent();

function handleOnDoubleClickLetter {
    letterEvent.HandleOnDoubleClick();
}

function backgroundSetCount(count) {
    backgroundEvent.SetCount(count);
}

function backgroundCount {
    return backgroundEvent.Count();
}

function checkEventsOnSec {
    if(Shiori.Reference[3]==0){
        return "";
    }
    local background = backgroundEvent.CheckOnSec();
    local bird = birdEvent.CheckOnSec();
    local letter = letterEvent.CheckOnSec();

    if(letter.length>0){
        if(bird.length>0){
            letterEvent.ShiftTiming(letter);
            return background + bird;
        }
        else {
            return background + letter;
        }
    }

    return background + bird;
}

function OnRandomTalk {
    if(Save.Data.BirdExists){
        birdEvent.parameter.AddCount();
        return Reflection.Get("小鳥トーク"+birdEvent.parameter.tone);
    }
    return OnRandomTalkSilent;
}

function OnRandomTalkSilent {
    return "";
}

function 小鳥一人称 {
    return birdEvent.parameter.firstPerson;
}

function OnSecondChange {
    return checkEventsOnSec();
}
