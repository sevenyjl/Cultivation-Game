package com.seven.game.cultivation.entity;

import cn.hutool.core.util.RandomUtil;
import lombok.Data;
import lombok.experimental.Accessors;

/**
 * 范围值
 * 用于范围值，比如 生命值，灵气值
 */
@Data
@Accessors(chain = true)
public class RangeValue extends GrowthAttribute {
    private Double minValue;
    private Double maxValue;

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
