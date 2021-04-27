AnimatedHealthLossMixin = {};

function AnimatedHealthLossMixin:OnLoad()
	self:SetStatusBarColor(1, 0, 0, 1);
	self:SetDuration(.25);
	self:SetStartDelay(.1);
	self:SetPauseDelay(.05);
	self:SetPostponeDelay(.05);
end

function AnimatedHealthLossMixin:SetDuration(duration)
	self.animationDuration = duration or 0;
end

function AnimatedHealthLossMixin:SetStartDelay(delay)
	self.animationStartDelay = delay or 0;
end

function AnimatedHealthLossMixin:SetPauseDelay(delay)
	self.animationPauseDelay = delay or 0;
end

function AnimatedHealthLossMixin:SetPostponeDelay(delay)
	self.animationPostponeDelay = delay or 0;
end

function AnimatedHealthLossMixin:SetUnitHealthBar(unit, healthBar)
	if self.unit ~= unit then
		healthBar.AnimatedLossBar = self;
		self.unit = unit;
		self:SetAllPoints(healthBar);
		self:UpdateHealthMinMax();
	end
end

function AnimatedHealthLossMixin:UpdateHealthMinMax()
	local maxValue = UnitHealthMax(self.unit);
	self:SetMinMaxValues(0, maxValue);
end

function AnimatedHealthLossMixin:GetHealthLossAnimationData(currentHealth, previousHealth)
	if self.animationStartTime then
		local totalElapsedTime = GetTime() - self.animationStartTime;
		if totalElapsedTime > 0 then
			local animCompletePercent = totalElapsedTime / self.animationDuration;
			if animCompletePercent < 1 and previousHealth > currentHealth then
				local healthDelta = previousHealth - currentHealth;
				local animatedLossAmount = previousHealth - (animCompletePercent * healthDelta);
				return animatedLossAmount, animCompletePercent;
			end
		else
			return previousHealth, 0;
		end
	end
	return 0, 1; -- Animated loss amount is 0, and the animation is fully complete.
end

function AnimatedHealthLossMixin:CancelAnimation()
	self:Hide();
	self.animationStartTime = nil;
	self.animationCompletePercent = nil;
end

function AnimatedHealthLossMixin:BeginAnimation(value)
	self.animationStartValue = value;
	self.animationStartTime = GetTime() + self.animationStartDelay;
	self.animationCompletePercent = 0;
	self:Show();
	self:SetValue(self.animationStartValue);
end

function AnimatedHealthLossMixin:PostponeStartTime()
	self.animationStartTime = self.animationStartTime + self.animationPostponeDelay;
end

function AnimatedHealthLossMixin:UpdateHealth(currentHealth, previousHealth)
	local delta = currentHealth - previousHealth;
	local hasLoss = delta < 0;
	local hasBegun = self.animationStartTime ~= nil;
	local isAnimating = hasBegun and self.animationCompletePercent > 0;
	if hasLoss and not hasBegun then
		self:BeginAnimation(previousHealth);
	elseif hasLoss and hasBegun and not isAnimating then
		self:PostponeStartTime();
	elseif hasLoss and isAnimating then
		-- Reset the starting value of the health to what the animated loss bar was when the new incoming damage happened
		-- and pause briefly when new damage occurs.
		self.animationStartValue = self:GetHealthLossAnimationData(previousHealth, self.animationStartValue);
		self.animationStartTime = GetTime() + self.animationPauseDelay;
	elseif not hasLoss and hasBegun and currentHealth >= self.animationStartValue then
		self:CancelAnimation();
	end
end

function AnimatedHealthLossMixin:UpdateLossAnimation(currentHealth)
	local totalAbsorb = UnitGetTotalAbsorbs(self.unit) or 0;
	if totalAbsorb > 0 then
		self:CancelAnimation();
	end
	if self.animationStartTime then
		local animationValue, animationCompletePercent = self:GetHealthLossAnimationData(currentHealth, self.animationStartValue);
		self.animationCompletePercent = animationCompletePercent;
		if animationCompletePercent >= 1 then
			self:CancelAnimation();
		else
			self:SetValue(animationValue);
		end
	end
end