package com.seven.game.cultivation.entity;

import cn.hutool.core.util.RandomUtil;
import lombok.Data;
import lombok.experimental.Accessors;

/**
 * 成长属性
 * 用于具体的值，比如等级
 */
@Data
@Accessors(chain = true)
public class GrowthAttribute {
    private String name;
    private float currentValue;
    /**
     * 成长最小增量
     */
    private float minGrowthDelta;
    /**
     * 成长最大增量
     */
    private float maxGrowthDelta;

    public void grow() {
        float delta = RandomUtil.randomFloat(minGrowthDelta, maxGrowthDelta);
        currentValue += Math.round(delta * 100.0f) / 100.0f;
    }
}
