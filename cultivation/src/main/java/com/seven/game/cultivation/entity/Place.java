package com.seven.game.cultivation.entity;

import cn.hutool.core.util.IdUtil;
import com.seven.game.cultivation.entity.attribute.RandomValue;
import com.seven.game.cultivation.entity.attribute.RangeValue;
import com.seven.game.cultivation.utils.NameUtils;
import lombok.Data;

/**
 * 地点实体类
 */
@Data
public class Place {
    private String id;
    private String name;
    private String description;
    /**
     * 地点的灵气存储范围
     * min=0, max=100 current 就是当前灵气值
     */
    private RangeValue lingQiStorage;
    private RandomValue 生产灵气速度;
    private RangeValue 剩余未生产灵气值;


    public void action(){
        // 生产灵气
        double 生产灵气值 = 生产灵气速度.getCurrentValue();
        剩余未生产灵气值.setCurrentValue(剩余未生产灵气值.getCurrentValue() + 生产灵气值);
        lingQiStorage.setCurrentValue(lingQiStorage.getCurrentValue() + 生产灵气值);
    }
    /**
     * 用于随机分配属性值（mock地点）
     *
     * @return
     */
    public Place randomAssignmentMethod() {
        id = IdUtil.fastSimpleUUID();
        name = NameUtils.generateLocationName();
        description = NameUtils.generateLocationDescription(name);
        lingQiStorage = (RangeValue) new RangeValue()
                .setMinValue(0.0)
                .setMaxValue(100.0)
                .setCurrentValue(0.0)
                .setMinGrowthDelta(0.0)
                .setMaxGrowthDelta(1.0)
                .setName("灵气存储");
        生产灵气速度 = (RandomValue) new RandomValue()
                .setMinValue(1.0)
                .setMaxValue(10.0)
                .setMinGrowthDelta(0.0)
                .setMaxGrowthDelta(1.0)
                .setName("生产灵气速度");
        剩余未生产灵气值 = (RangeValue) new RangeValue()
                .setMinValue(0.0)
                .setMaxValue(100.0)
                .setCurrentValue(1.0)
                .setMinGrowthDelta(1.0)
                .setName("剩余未生产灵气值");
        return this;
    }
}
