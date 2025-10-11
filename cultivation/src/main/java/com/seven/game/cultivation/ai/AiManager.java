package com.seven.game.cultivation.ai;

import com.seven.game.cultivation.core.TimePasses;
import com.seven.game.cultivation.entity.BaseCultivator;
import com.seven.game.cultivation.manager.CultivatorManager;
import jakarta.annotation.Resource;
import lombok.Data;
import lombok.experimental.Accessors;
import org.springframework.stereotype.Component;

/**
 * AI修炼者管理器
 * 用于存储和管理所有的AI修炼者
 * 提供添加、删除、查找、批量操作等功能
 */
@Data
@Accessors(chain = true)
@Component
public class AiManager implements TimePasses {
    @Resource
    private CultivatorManager cultivatorManager;

    /**
     * 对所有的AI修炼者进行时间流逝处理
     */
    @Override
    public void timePasses() {
        cultivatorManager.getAllCultivators().forEach(BaseCultivator::action);
    }
}