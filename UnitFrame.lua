local LibAbsorb  = LibStub:GetLibrary("AbsorbsMonitor-1.0");
local HealComm   = LibStub:GetLibrary("LibHealComm-4.0");
local LibTimer   = LibStub:GetLibrary("AceTimer-3.0");

local callbackTime = 0.1;

PowerBarColor = PowerBarColor or {};
PowerBarColor["RAGE"] = { r = 1.00, g = 0.00, b = 0.00, fullPowerAnim=true };
PowerBarColor["FOCUS"] = { r = 1.00, g = 0.50, b = 0.25, fullPowerAnim=true };
PowerBarColor["ENERGY"] = { r = 1.00, g = 1.00, b = 0.00, fullPowerAnim=true };

function GetPowerBarColor(powerType)
	return PowerBarColor[powerType];
end

function UnitGetIncomingHeals(unit, healer)
	if not ( unit and HealComm ) then
		return;
	end

	if ( healer ) then
		return HealComm:GetCasterHealAmount(UnitGUID(healer), HealComm.CASTED_HEALS, GetTime() + 5);
	else
		return HealComm:GetHealAmount(UnitGUID(unit), HealComm.ALL_HEALS, GetTime() + 5);
	end
end

function UnitGetTotalAbsorbs(unit)
	if not ( unit and LibAbsorb ) then
		return;
	end

	return LibAbsorb.Unit_Total(UnitGUID(unit));
end

function UnitGetTotalHealAbsorbs(unit) -- there is nothing like this in the WotLK patch
	return;
end

local function UnitFrameUtil_UpdateFillBarBase(frame, realbar, previousTexture, bar, amount, barOffsetXPercent)
	if ( amount == 0 ) then
		bar:Hide();
		if ( bar.overlay ) then
			bar.overlay:Hide();
		end
		return previousTexture;
	end
	local barOffsetX = 0;
	if ( barOffsetXPercent ) then
		local realbarSizeX = realbar:GetWidth();
		barOffsetX = realbarSizeX * barOffsetXPercent;
	end
	bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT", barOffsetX, 0);
	bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT", barOffsetX, 0);
	local totalWidth, totalHeight = realbar:GetSize();
	local _, totalMax = realbar:GetMinMaxValues();
	local barSize = (amount / totalMax) * totalWidth;
	bar:SetWidth(barSize);
	bar:Show();

	if ( bar.overlay ) then
		bar.overlay:SetTexCoord(0, barSize / bar.overlay.tileSize, 0, totalHeight / bar.overlay.tileSize);
		bar.overlay:Show();
	end
	return bar;
end

local function UnitFrameUtil_UpdateFillBar(frame, previousTexture, bar, amount, barOffsetXPercent)
	return UnitFrameUtil_UpdateFillBarBase(frame, frame.healthbar, previousTexture, bar, amount, barOffsetXPercent);
end

local MAX_INCOMING_HEAL_OVERFLOW = 1.0;
local function UnitFrameHealPredictionBars_Update(frame)
	if ( not frame.myHealPredictionBar ) then
		return;
	end
	local _, maxHealth = frame.healthbar:GetMinMaxValues();
	local health = frame.healthbar:GetValue();
	if ( maxHealth <= 0 ) then
		return;
	end
	local myIncomingHeal = UnitGetIncomingHeals(frame.unit, "player") or 0;
	local allIncomingHeal = UnitGetIncomingHeals(frame.unit) or 0;
	local totalAbsorb = UnitGetTotalAbsorbs(frame.unit) or 0;
	local myCurrentHealAbsorb = 0;

	if ( frame.healAbsorbBar ) then
		myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(frame.unit) or 0;
		--We don't fill outside the health bar with healAbsorbs.  Instead, an overHealAbsorbGlow is shown.
		if ( health < myCurrentHealAbsorb ) then
			frame.overHealAbsorbGlow:Show();
			myCurrentHealAbsorb = health;
		else
			frame.overHealAbsorbGlow:Hide();
		end
	end
	--See how far we're going over the health bar and make sure we don't go too far out of the frame.
	if ( health - myCurrentHealAbsorb + allIncomingHeal > maxHealth * MAX_INCOMING_HEAL_OVERFLOW ) then
		allIncomingHeal = maxHealth * MAX_INCOMING_HEAL_OVERFLOW - health + myCurrentHealAbsorb;
	end
	local otherIncomingHeal = 0;
	--Split up incoming heals.
	if ( allIncomingHeal >= myIncomingHeal ) then
		otherIncomingHeal = allIncomingHeal - myIncomingHeal;
	else
		myIncomingHeal = allIncomingHeal;
	end
	--We don't fill outside the the health bar with absorbs.  Instead, an overAbsorbGlow is shown.
	local overAbsorb = false;
	if ( health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth ) then
		if ( totalAbsorb > 0 ) then
			overAbsorb = true;
		end
		if ( allIncomingHeal > myCurrentHealAbsorb ) then
			totalAbsorb = max(0,maxHealth - (health - myCurrentHealAbsorb + allIncomingHeal));
		else
			totalAbsorb = max(0,maxHealth - health);
		end
	end

	if ( overAbsorb ) then
		frame.overAbsorbGlow:Show();
	else
		frame.overAbsorbGlow:Hide();
	end
	local healthTexture = frame.healthbar:GetStatusBarTexture();
	local myCurrentHealAbsorbPercent = 0;
	local healAbsorbTexture = nil;
	if ( frame.healAbsorbBar ) then
		myCurrentHealAbsorbPercent = myCurrentHealAbsorb / maxHealth;
		--If allIncomingHeal is greater than myCurrentHealAbsorb, then the current
		--heal absorb will be completely overlayed by the incoming heals so we don't show it.
		if ( myCurrentHealAbsorb > allIncomingHeal ) then
			local shownHealAbsorb = myCurrentHealAbsorb - allIncomingHeal;
			local shownHealAbsorbPercent = shownHealAbsorb / maxHealth;
			healAbsorbTexture = UnitFrameUtil_UpdateFillBar(frame, healthTexture, frame.healAbsorbBar, shownHealAbsorb, -shownHealAbsorbPercent);
			--If there are incoming heals the left shadow would be overlayed by the incoming heals
			--so it isn't shown.
			if ( allIncomingHeal > 0 ) then
				frame.healAbsorbBarLeftShadow:Hide();
			else
				frame.healAbsorbBarLeftShadow:SetPoint("TOPLEFT", healAbsorbTexture, "TOPLEFT", 0, 0);
				frame.healAbsorbBarLeftShadow:SetPoint("BOTTOMLEFT", healAbsorbTexture, "BOTTOMLEFT", 0, 0);
				frame.healAbsorbBarLeftShadow:Show();
			end
			-- The right shadow is only shown if there are absorbs on the health bar.
			if ( totalAbsorb > 0 ) then
				frame.healAbsorbBarRightShadow:SetPoint("TOPLEFT", healAbsorbTexture, "TOPRIGHT", -8, 0);
				frame.healAbsorbBarRightShadow:SetPoint("BOTTOMLEFT", healAbsorbTexture, "BOTTOMRIGHT", -8, 0);
				frame.healAbsorbBarRightShadow:Show();
			else
				frame.healAbsorbBarRightShadow:Hide();
			end
		else
			frame.healAbsorbBar:Hide();
			frame.healAbsorbBarLeftShadow:Hide();
			frame.healAbsorbBarRightShadow:Hide();
		end
    end
--Show myIncomingHeal on the health bar.
	local incomingHealTexture = UnitFrameUtil_UpdateFillBar(frame, healthTexture, frame.myHealPredictionBar, myIncomingHeal, -myCurrentHealAbsorbPercent);
	--Append otherIncomingHeal on the health bar
	if (myIncomingHeal > 0) then
		incomingHealTexture = UnitFrameUtil_UpdateFillBar(frame, incomingHealTexture, frame.otherHealPredictionBar, otherIncomingHeal);
	else
		incomingHealTexture = UnitFrameUtil_UpdateFillBar(frame, healthTexture, frame.otherHealPredictionBar, otherIncomingHeal, -myCurrentHealAbsorbPercent);
	end
	--Append absorbs to the correct section of the health bar.
	local appendTexture = nil;
	if ( healAbsorbTexture ) then
		--If there is a healAbsorb part shown, append the absorb to the end of that.
		appendTexture = healAbsorbTexture;
	else
		--Otherwise, append the absorb to the end of the the incomingHeals part;
		appendTexture = incomingHealTexture;
	end
	UnitFrameUtil_UpdateFillBar(frame, appendTexture, frame.totalAbsorbBar, totalAbsorb)
end

local function C_TimeCallback(self)
	LibTimer:ScheduleTimer(function()
		UnitFrameHealPredictionBars_Update(self)
	end, callbackTime);
end

local function LibEventCallback(self, event, ... )
    local arg1, arg2, arg3, arg4, arg5 = ...;
    if ( not UnitExists(self.unit) ) then
        return;
    end

    if ( event == "HealComm_HealStarted" or event == "HealComm_HealStopped" ) then
        C_TimeCallback(self);
    elseif ( event == "EffectApplied" ) then
        if ( arg3 == UnitGUID(self.unit) ) then
            C_TimeCallback(self);
        end
    elseif ( event == "HealComm_HealUpdated" )
        or ( event == "HealComm_HealStarted" )
        or ( event == "HealComm_HealDelayed" )
        or ( event == "HealComm_ModifierChanged" )
        or ( event == "HealComm_GUIDDisappeared" ) then
            if ( arg5 == UnitGUID(self.unit) ) then
                C_TimeCallback(self);
            end
    end
end

local function UnitFrame_RegisterCallback(self)
    LibAbsorb.RegisterCallback(self, "EffectApplied", LibEventCallback, self);

    HealComm.RegisterCallback(self, "HealComm_HealStarted", LibEventCallback, self);
    HealComm.RegisterCallback(self, "HealComm_HealUpdated", LibEventCallback, self);
    HealComm.RegisterCallback(self, "HealComm_HealDelayed", LibEventCallback, self);
    HealComm.RegisterCallback(self, "HealComm_HealStopped", LibEventCallback, self);
    HealComm.RegisterCallback(self, "HealComm_ModifierChanged", LibEventCallback, self);
    HealComm.RegisterCallback(self, "HealComm_GUIDDisappeared", LibEventCallback, self);
end

local function UnitFrameLayer_Initialize(self, myHealPredictionBar, otherHealPredictionBar, totalAbsorbBar, totalAbsorbBarOverlay,
	overAbsorbGlow, overHealAbsorbGlow, healAbsorbBar, healAbsorbBarLeftShadow, healAbsorbBarRightShadow, myManaCostPredictionBar)

	self.myHealPredictionBar = myHealPredictionBar;
	self.otherHealPredictionBar = otherHealPredictionBar
	self.totalAbsorbBar = totalAbsorbBar;
	self.totalAbsorbBarOverlay = totalAbsorbBarOverlay;
	self.overAbsorbGlow = overAbsorbGlow;
	self.overHealAbsorbGlow = overHealAbsorbGlow;
	self.healAbsorbBar = healAbsorbBar;
	self.healAbsorbBarLeftShadow = healAbsorbBarLeftShadow;
	self.healAbsorbBarRightShadow = healAbsorbBarRightShadow;
	self.myManaCostPredictionBar = myManaCostPredictionBar;

	if ( self.unit == "player" ) then 
		self.myManaCostPredictionBar:ClearAllPoints();

		self:RegisterEvent("UNIT_SPELLCAST_START");
		self:RegisterEvent("UNIT_SPELLCAST_STOP");
		self:RegisterEvent("UNIT_SPELLCAST_FAILED");
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	else
		self.myManaCostPredictionBar:Hide();
	end

    self.myHealPredictionBar:ClearAllPoints();

    self.otherHealPredictionBar:ClearAllPoints();

    self.totalAbsorbBar:ClearAllPoints();

    self.totalAbsorbBar.overlay = self.totalAbsorbBarOverlay;
    self.totalAbsorbBarOverlay:SetAllPoints(self.totalAbsorbBar);
    self.totalAbsorbBarOverlay.tileSize = 32;

    self.overAbsorbGlow:ClearAllPoints();
	self.overAbsorbGlow:SetWidth(16);
    self.overAbsorbGlow:SetPoint("TOPLEFT", self.healthbar, "TOPRIGHT", -7, 0);
    self.overAbsorbGlow:SetPoint("BOTTOMLEFT", self.healthbar, "BOTTOMRIGHT",  -7, 0);

    self.healAbsorbBar:ClearAllPoints();
    self.healAbsorbBar:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);

    self.overHealAbsorbGlow:ClearAllPoints();
    self.overHealAbsorbGlow:SetPoint("BOTTOMRIGHT", self.healthbar, "BOTTOMLEFT", 7, 0);
    self.overHealAbsorbGlow:SetPoint("TOPRIGHT", self.healthbar, "TOPLEFT", 7, 0);

    self.healAbsorbBarLeftShadow:ClearAllPoints();

    self.healAbsorbBarRightShadow:ClearAllPoints();

	self:RegisterEvent("UNIT_MAXHEALTH");
    UnitFrame_RegisterCallback(self);

	if ( self.unit == "player" ) then
		self.PlayerFrameHealthBarAnimatedLoss = CreateFrame("StatusBar", nil, self, "PlayerFrameHealthBarAnimatedLossTemplate");
		self.PlayerFrameHealthBarAnimatedLoss:SetUnitHealthBar("player", self.healthbar);
		self.PlayerFrameHealthBarAnimatedLoss:SetFrameLevel(self.healthbar:GetFrameLevel() - 1)

		if ( self.manabar ) then
			self.manabar.FeedbackFrame = CreateFrame("Frame", nil, self.manabar, "BuilderSpenderFrame");
			self.manabar.FeedbackFrame:SetAllPoints();
			self.manabar.FeedbackFrame:SetFrameLevel(self:GetParent():GetFrameLevel() + 1);

			self.manabar.FullPowerFrame = CreateFrame("Frame", nil, self.manabar, "FullPowerFrameTemplate");

			self.manabar:SetScript("OnUpdate", UnitFrameManaBar_OnUpdate);
		end
	end

	UnitFrame_Update(self);
end

function UnitFrameHealthBar_OnUpdate(self)
	if ( not self.disconnected and not self.lockValues) then
		local currValue = UnitHealth(self.unit);
		local animatedLossBar = self.AnimatedLossBar;
		if ( currValue ~= self.currValue ) then
			if ( not self.ignoreNoUnit or UnitGUID(self.unit) ) then
				if animatedLossBar then
					animatedLossBar:UpdateHealth(currValue, self.currValue);
				end
				self:SetValue(currValue);
				self.currValue = currValue;
				TextStatusBar_UpdateTextString(self);
				UnitFrameHealPredictionBars_Update(self:GetParent());
			end
		end
		if animatedLossBar then
			animatedLossBar:UpdateLossAnimation(currValue);
		end
	end
end

function UnitFrameManaBar_OnUpdate(self)
	if ( not self.disconnected and not self.lockValues ) then
		local predictedCost = self:GetParent().predictedPowerCost;
		local currValue = UnitPower(self.unit, self.powerType);
		if (predictedCost) then
			currValue = currValue - predictedCost;
		end
		if ( currValue ~= self.currValue or self.forceUpdate ) then
			self.forceUpdate = nil;
			if ( not self.ignoreNoUnit or UnitGUID(self.unit) ) then
				if ( self.FeedbackFrame ) then
					-- Only show anim if change is more than 10%
					local oldValue = self.currValue or 0;
					if ( self.FeedbackFrame.maxValue ~= 0 and math.abs(currValue - oldValue) / self.FeedbackFrame.maxValue > 0.1 ) then
						self.FeedbackFrame:StartFeedbackAnim(oldValue, currValue);
					end
				end
				if ( self.FullPowerFrame and self.FullPowerFrame.active ) then
					self.FullPowerFrame:StartAnimIfFull(self.currValue or 0, currValue);
				end
				self:SetValue(currValue);
				self.currValue = currValue;
				TextStatusBar_UpdateTextString(self);
			end
		end
	end
end

function UnitFrameManaBar_Update(statusbar, unit)
	if ( not statusbar or statusbar.lockValues ) then
		return;
	end
	if ( unit == statusbar.unit ) then
		-- be sure to update the power type before grabbing the max power!
		UnitFrameManaBar_UpdateType(statusbar);
		local maxValue = UnitPowerMax(unit, statusbar.powerType);
		statusbar:SetMinMaxValues(0, maxValue);
		statusbar.disconnected = not UnitIsConnected(unit);
		if ( statusbar.disconnected ) then
			statusbar:SetValue(maxValue);
			statusbar.currValue = maxValue;
			if ( not statusbar.lockColor ) then
				statusbar:SetStatusBarColor(0.5, 0.5, 0.5);
			end
		else
			local predictedCost = statusbar:GetParent().predictedPowerCost;
			local currValue = UnitPower(unit, statusbar.powerType);
			if (predictedCost) then
				currValue = currValue - predictedCost;
			end
			if ( statusbar.FullPowerFrame ) then
				statusbar.FullPowerFrame:SetMaxValue(maxValue);
			end
			statusbar:SetValue(currValue);
			statusbar.forceUpdate = true;
		end
	end
	TextStatusBar_UpdateTextString(statusbar);
end

local function UnitFrameUtil_UpdateManaFillBar(frame, previousTexture, bar, amount, barOffsetXPercent)
	return UnitFrameUtil_UpdateFillBarBase(frame, frame.manabar, previousTexture, bar, amount, barOffsetXPercent);
end

local function UnitFrameManaCostPredictionBars_Update(frame, isStarting, startTime, endTime, spellID)
	if (not frame.manabar or not frame.myManaCostPredictionBar) then
		return;
	end
	local cost = 0;
	if (not isStarting or startTime == endTime) then
        local currentSpellID = select(9, UnitCastingInfo(frame.unit));
        if(currentSpellID and frame.predictedPowerCost) then --if we're currently casting something with a power cost, then whatever cast
		    cost = frame.predictedPowerCost;                 --just finished was allowed while casting, don't reset the original cast
        else
            frame.predictedPowerCost = nil;
        end
	else
		local costTable = GetSpellPowerCost(spellID);
		for _, costInfo in pairs(costTable) do
			if (costInfo.type == frame.manabar.powerType) then
				cost = costInfo.cost;
				break;
			end
		end
		frame.predictedPowerCost = cost;
	end
	local manaBarTexture = frame.manabar:GetStatusBarTexture();
	UnitFrameManaBar_Update(frame.manabar, frame.unit);
	UnitFrameUtil_UpdateManaFillBar(frame, manaBarTexture, frame.myManaCostPredictionBar, cost);
end

function UnitFrameManaBar_UpdateType(manaBar)
	if ( not manaBar ) then
		return;
	end
	local unitFrame = manaBar:GetParent();
	local powerType, powerToken, altR, altG, altB = UnitPowerType(manaBar.unit);
	local prefix = _G[powerToken];
	local info = PowerBarColor[powerToken];
	if ( info ) then
		if ( not manaBar.lockColor ) then
			local playerDeadOrGhost = (manaBar.unit == "player" and (UnitIsDead("player") or UnitIsGhost("player")));
			if ( info.atlas ) then
				manaBar:SetStatusBarAtlas(info.atlas);
				manaBar:SetStatusBarColor(1, 1, 1);
				manaBar:GetStatusBarTexture():SetDesaturated(playerDeadOrGhost);
				manaBar:GetStatusBarTexture():SetAlpha(playerDeadOrGhost and 0.5 or 1);
			else
				manaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
				if ( playerDeadOrGhost ) then
					manaBar:SetStatusBarColor(0.6, 0.6, 0.6, 0.5);
				else
					manaBar:SetStatusBarColor(info.r, info.g, info.b);
				end
			end
			if ( manaBar.FeedbackFrame ) then
				manaBar.FeedbackFrame:Initialize(info, manaBar.unit, powerType);
			end
			if ( manaBar.FullPowerFrame ) then
				manaBar.FullPowerFrame:Initialize(info.fullPowerAnim);
			end
		end
	else
		if ( not altR) then
			-- couldn't find a power token entry...default to indexing by power type or just mana if we don't have that either
			info = PowerBarColor[powerType] or PowerBarColor["MANA"];
		else
			if ( not manaBar.lockColor ) then
				manaBar:SetStatusBarColor(altR, altG, altB);
			end
		end
	end
	if ( manaBar.powerType ~= powerType or manaBar.powerType ~= powerType ) then
		manaBar.powerType = powerType;
		manaBar.powerToken = powerToken;
		if ( manaBar.FullPowerFrame ) then
			manaBar.FullPowerFrame:RemoveAnims();
		end
		if manaBar.FeedbackFrame then
			manaBar.FeedbackFrame:StopFeedbackAnim();
		end
		manaBar.currValue = UnitPower("player", powerType);
		if unitFrame.myManaCostPredictionBar then
			unitFrame.myManaCostPredictionBar:Hide();
		end
		unitFrame.predictedPowerCost = 0;
	end

	-- Update the manabar text
	if ( not unitFrame.noTextPrefix ) then
		SetTextStatusBarTextPrefix(manaBar, prefix);
	end
	TextStatusBar_UpdateTextString(manaBar);
	-- Setup newbie tooltip
	if ( manaBar.unit ~= "pet") then
		if ( unitFrame:GetName() == "PlayerFrame" ) then
			manaBar.tooltipTitle = prefix;
			manaBar.tooltipText = _G["NEWBIE_TOOLTIP_MANABAR_"..powerType];
		else
			manaBar.tooltipTitle = nil;
			manaBar.tooltipText = nil;
		end
	end
end

local function UnitFrameHealPredictionBars_UpdateMax(self)
	if ( not self.myHealPredictionBar ) then
		return;
	end
	UnitFrameHealPredictionBars_Update(self);
end

hooksecurefunc("UnitFrameHealthBar_Update", function(statusbar, unit)
	if statusbar.AnimatedLossBar then
		statusbar.AnimatedLossBar:UpdateHealthMinMax();
	end
	UnitFrameHealPredictionBars_Update(statusbar:GetParent());
end);

hooksecurefunc("UnitFrame_Update", function(self, isParty)
	UnitFrameHealPredictionBars_UpdateMax(self);
	UnitFrameHealPredictionBars_Update(self);
	UnitFrameManaCostPredictionBars_Update(self);
end);

hooksecurefunc("UnitFrame_OnEvent", function(self, event, ...)

	if ( not self.myHealPredictionBar ) then
		CreateFrame("Frame", nil, self, "StatusBarHealPredictionTemplate");
		local thisName = self:GetName();

		UnitFrameLayer_Initialize(self, _G[thisName.."FrameMyHealPredictionBar"], _G[thisName.."FrameOtherHealPredictionBar"],
									_G[thisName.."TotalAbsorbBar"], _G[thisName.."TotalAbsorbBarOverlay"],
									_G[thisName.."FrameOverAbsorbGlow"], _G[thisName.."OverHealAbsorbGlow"],
									_G[thisName.."HealAbsorbBar"], _G[thisName.."HealAbsorbBarLeftShadow"],
									_G[thisName.."HealAbsorbBarRightShadow"], _G[thisName.."FrameManaCostPredictionBar"]);
	end

	UnitFrameHealPredictionBars_Update(self);

	if ( event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_SUCCEEDED" ) then
		local unit = ...;
		if ( UnitIsUnit(unit, "player") ) then
			local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit);
			UnitFrameManaCostPredictionBars_Update(self, event == "UNIT_SPELLCAST_START", startTime, endTime, spellID);
		end
	end
end)