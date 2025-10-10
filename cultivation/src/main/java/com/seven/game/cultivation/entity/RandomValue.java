package com.seven.game.cultivation.entity;

import cn.hutool.core.util.RandomUtil;
import lombok.Data;
import lombok.experimental.Accessors;

import java.math.BigDecimal;

/**
 * 随机值
 * 用于随机值，比如 攻击力、防御力
 */
@Data
@Accessors(chain = true)
public class RandomValue extends RangeValue {

    @Override
    public Double getCurrentValue() {
        // 保留两位小数
        return RandomUtil.randomDouble(getMinValue(), getMaxValue());
    }
}
