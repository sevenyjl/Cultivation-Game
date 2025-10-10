package com.seven.game.cultivation.entity;

import cn.hutool.core.util.RandomUtil;
import lombok.Data;
import lombok.experimental.Accessors;
/**
 * 随机值
 * 用于随机值，比如 攻击力、防御力
 */
@Data
@Accessors(chain = true)
public class RandomValue extends RangeValue {

    @Override
    public float getCurrentValue() {
        return Math.round(RandomUtil.randomFloat(getMinValue(), getMaxValue()) * 100.0f) / 100.0f;
    }
}
