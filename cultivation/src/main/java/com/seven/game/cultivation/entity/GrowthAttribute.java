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
    private Double currentValue;
    /**
     * 成长最小增量
     */
    private Double minGrowthDelta;
    /**
     * 成长最大增量
     */
    private Double maxGrowthDelta;


    public void grow() {
        float delta = RandomUtil.randomFloat(
            minGrowthDelta.floatValue(), 
            maxGrowthDelta.floatValue()
        );
        this.currentValue += delta;
    }

}