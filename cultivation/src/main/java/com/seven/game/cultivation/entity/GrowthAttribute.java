package com.seven.game.cultivation.entity;

import cn.hutool.core.util.RandomUtil;
import lombok.Data;
import lombok.experimental.Accessors;
import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * 成长属性
 * 使用BigDecimal确保精度
 */
@Data
@Accessors(chain = true)
public class GrowthAttribute {
    private String name;
    private BigDecimal currentValue;
    /**
     * 成长最小增量
     */
    private BigDecimal minGrowthDelta;
    /**
     * 成长最大增量
     */
    private BigDecimal maxGrowthDelta;

    protected static final int SCALE = 2;
    protected static final RoundingMode ROUNDING_MODE = RoundingMode.HALF_UP;

    public void grow() {
        float delta = RandomUtil.randomFloat(
            minGrowthDelta.floatValue(), 
            maxGrowthDelta.floatValue()
        );
        BigDecimal formattedDelta = new BigDecimal(delta).setScale(SCALE, ROUNDING_MODE);
        this.currentValue = this.currentValue.add(formattedDelta);
    }
    
    // 便捷的float设置方法
    public GrowthAttribute setCurrentValue(float value) {
        this.currentValue = new BigDecimal(value).setScale(SCALE, ROUNDING_MODE);
        return this;
    }
    
    public GrowthAttribute setMinGrowthDelta(float value) {
        this.minGrowthDelta = new BigDecimal(value).setScale(SCALE, ROUNDING_MODE);
        return this;
    }
    
    public GrowthAttribute setMaxGrowthDelta(float value) {
        this.maxGrowthDelta = new BigDecimal(value).setScale(SCALE, ROUNDING_MODE);
        return this;
    }
}