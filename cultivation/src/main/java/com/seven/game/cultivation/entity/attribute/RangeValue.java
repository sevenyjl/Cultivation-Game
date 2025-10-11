package com.seven.game.cultivation.entity.attribute;

import cn.hutool.core.util.RandomUtil;
import lombok.Data;
import lombok.ToString;
import lombok.experimental.Accessors;

/**
 * 范围值
 * 用于范围值，比如 生命值，灵气值
 */
@Data
@Accessors(chain = true)
@ToString(callSuper = true)
public class RangeValue extends GrowthAttribute {
    private Double minValue;
    private Double maxValue;

    @Override
    public GrowthAttribute setCurrentValue(Double currentValue) {
        currentValue = Math.max(currentValue, minValue);
        currentValue = Math.min(currentValue, maxValue);
        return super.setCurrentValue(currentValue);
    }

    @Override
    public void grow() {
        super.grow();
        try {
            double v = RandomUtil.randomDouble(minValue, maxValue);
            double maxAddValue = RandomUtil.randomDouble(v / 2, v);
            minValue = minValue + (v - maxAddValue);
            maxValue = maxValue + maxAddValue;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
