package com.seven.game.cultivation.entity;

import cn.hutool.core.util.RandomUtil;
import lombok.Data;
import lombok.experimental.Accessors;

import java.math.BigDecimal;

/**
 * 范围值
 * 用于范围值，比如 生命值，灵气值
 */
@Data
@Accessors(chain = true)
public class RangeValue extends GrowthAttribute {
    private BigDecimal minValue;
    private BigDecimal maxValue;

    @Override
    public void grow() {
        super.grow();
        float v = RandomUtil.randomFloat(minValue.floatValue(), maxValue.floatValue());
        float maxAddValue = RandomUtil.randomFloat(v / 2, v);
        try {
            minValue = minValue.add(new BigDecimal(v - maxAddValue));
            maxValue = maxValue.add(new BigDecimal(maxAddValue));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public RangeValue setMinValue(float value) {
        this.minValue = new BigDecimal(value).setScale(SCALE, ROUNDING_MODE);
        return this;
    }

    public RangeValue setMaxValue(float value) {
        this.maxValue = new BigDecimal(value).setScale(SCALE, ROUNDING_MODE);
        return this;
    }
}
