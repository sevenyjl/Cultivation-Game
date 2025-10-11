package com.seven.game.cultivation.entity;

import cn.hutool.core.util.RandomUtil;
import com.seven.game.cultivation.entity.attribute.GrowthAttribute;
import com.seven.game.cultivation.entity.attribute.RangeValue;
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
                .setMinGrowthDelta(1.0)
                .setMaxGrowthDelta(1.0)
                .setCurrentValue(1.0);
        hp= (RangeValue) new RangeValue()
                .setMinValue(100.0)
                .setMaxValue(RandomUtil.randomDouble(100, 200))
                .setCurrentValue(100.0)
                .setMinGrowthDelta(10.0)
                .setMaxGrowthDelta(20.0)
                .setName("生命值");
        atk= (RangeValue) new RangeValue()
                .setMinValue(10.0)
                .setMaxValue(RandomUtil.randomDouble(10, 20))
                .setCurrentValue(10.0)
                .setMinGrowthDelta(1.0)
                .setMaxGrowthDelta(2.0)
                .setName("攻击力");
        for (int i = 0; i < lv; i++) {
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
