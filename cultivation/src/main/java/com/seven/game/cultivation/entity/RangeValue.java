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
    private float minValue;
    private float maxValue;

    @Override
    public void grow() {
        super.grow();
        float v = RandomUtil.randomFloat(minValue, maxValue);
        float maxAddValue = Math.round(RandomUtil.randomFloat(v / 2, v) * 100.0f) / 100.0f;
        minValue += v - maxAddValue;
        maxValue += maxAddValue;
    }
}
