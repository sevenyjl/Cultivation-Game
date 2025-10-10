package com.seven.game.cultivation.entity;

import cn.hutool.core.util.RandomUtil;
import com.seven.game.cultivation.utils.NameUtils;
import lombok.Data;
import lombok.experimental.Accessors;

/**
 * 基础修炼者
 */
@Data
@Accessors(chain = true)
public class BaseCultivator {
    private String name;
    /**
     * 等级
     */
    private GrowthAttribute level;
    /**
     * 生命值
     */
    private RangeValue hp;

    /**
     * 攻击力
     */
    private RangeValue atk;


    /**
     * 用于随机分配属性值（mock修仙者）
     *
     * @return
     */
    public BaseCultivator randomAssignmentMethod() {
        name = NameUtils.generateCultivatorName();
        int lv=RandomUtil.randomInt(1, 10);
        level = new GrowthAttribute()
                .setName("等级")
                .setMinGrowthDelta(1)
                .setMaxGrowthDelta(1)
                .setCurrentValue(1);
        hp= (RangeValue) new RangeValue()
                .setMinValue(100)
                .setMaxValue(RandomUtil.randomInt(100, 200))
                .setCurrentValue(100)
                .setMinGrowthDelta(10)
                .setMaxGrowthDelta(20)
                .setName("生命值");
        atk= (RangeValue) new RangeValue()
                .setMinValue(10)
                .setMaxValue(RandomUtil.randomInt(10, 20))
                .setCurrentValue(10)
                .setMinGrowthDelta(1)
                .setMaxGrowthDelta(2)
                .setName("攻击力");
        for (int i = 0; i < level.getCurrentValue().intValue(); i++) {
            level.grow();
            hp.grow();
            atk.grow();
        }
        return this;
    }

    public static void main(String[] args) {
        // 测试随机分配属性值
        for (int i = 0; i < 10; i++) {
            BaseCultivator cultivator = new BaseCultivator().randomAssignmentMethod();
            System.out.println(cultivator);
        }
    }
}
