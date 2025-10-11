package com.seven.game.cultivation.ai;

import com.seven.game.cultivation.core.TimePasses;
import com.seven.game.cultivation.entity.BaseCultivator;
import lombok.Data;
import lombok.experimental.Accessors;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * AI修炼者管理器
 * 用于存储和管理所有的AI修炼者
 * 提供添加、删除、查找、批量操作等功能
 */
@Data
@Accessors(chain = true)
@Component
public class AiManager implements TimePasses {

    /**
     * 存储所有AI修炼者的映射表
     * key: 修炼者ID (UUID)
     * value: 修炼者对象
     */
    private Map<String, BaseCultivator> cultivators = new ConcurrentHashMap<>();

    /**
     * 按等级分组的修炼者映射表
     * key: 等级（整数）
     * value: 该等级的修炼者ID列表
     */
    private Map<Integer, List<String>> levelIndex = new ConcurrentHashMap<>();

    /**
     * 添加一个修炼者到管理器
     *
     * @param cultivator 要添加的修炼者
     * @return 生成的修炼者ID
     */
    public String addCultivator(BaseCultivator cultivator) {
        String id = UUID.randomUUID().toString();
        cultivators.put(id, cultivator);

        // 更新等级索引
        int level = cultivator.getLevel().getCurrentValue().intValue();
        levelIndex.computeIfAbsent(level, k -> new ArrayList<>()).add(id);

        return id;
    }

    /**
     * 批量添加修炼者
     *
     * @param cultivators 修炼者列表
     * @return 生成的ID列表
     */
    public List<String> addCultivators(List<BaseCultivator> cultivators) {
        return cultivators.stream()
                .map(this::addCultivator)
                .collect(Collectors.toList());
    }

    /**
     * 根据ID获取修炼者
     *
     * @param id 修炼者ID
     * @return 修炼者对象，如果不存在返回null
     */
    public BaseCultivator getCultivator(String id) {
        return cultivators.get(id);
    }

    /**
     * 根据ID删除修炼者
     *
     * @param id 要删除的修炼者ID
     * @return 被删除的修炼者，如果不存在返回null
     */
    public BaseCultivator removeCultivator(String id) {
        BaseCultivator removed = cultivators.remove(id);
        if (removed != null) {
            // 从等级索引中移除
            int level = removed.getLevel().getCurrentValue().intValue();
            levelIndex.getOrDefault(level, new ArrayList<>()).remove(id);
        }
        return removed;
    }

    /**
     * 根据名称查找修炼者（支持模糊查询）
     *
     * @param name 修炼者名称（支持部分匹配）
     * @return 匹配名称的修炼者列表
     */
    public List<BaseCultivator> findCultivatorsByName(String name) {
        return cultivators.values().stream()
                .filter(cultivator -> cultivator.getName().contains(name))
                .collect(Collectors.toList());
    }

    /**
     * 根据等级范围查找修炼者
     *
     * @param minLevel 最小等级（包含）
     * @param maxLevel 最大等级（包含）
     * @return 等级范围内的修炼者列表
     */
    public List<BaseCultivator> findCultivatorsByLevelRange(int minLevel, int maxLevel) {
        List<BaseCultivator> result = new ArrayList<>();
        for (int level = minLevel; level <= maxLevel; level++) {
            List<String> ids = levelIndex.get(level);
            if (ids != null) {
                ids.stream()
                        .map(cultivators::get)
                        .filter(Objects::nonNull)
                        .forEach(result::add);
            }
        }
        return result;
    }

    /**
     * 获取所有修炼者
     *
     * @return 所有修炼者的列表
     */
    public List<BaseCultivator> getAllCultivators() {
        return new ArrayList<>(cultivators.values());
    }

    /**
     * 获取所有修炼者ID
     *
     * @return 所有修炼者ID的集合
     */
    public Set<String> getAllCultivatorIds() {
        return cultivators.keySet();
    }

    /**
     * 获取修炼者数量
     *
     * @return 当前管理的修炼者总数
     */
    public int getCultivatorCount() {
        return cultivators.size();
    }

    /**
     * 清空所有修炼者
     */
    public void clearAll() {
        cultivators.clear();
        levelIndex.clear();
    }

    /**
     * 获取按等级分组的修炼者统计信息
     *
     * @return 等级统计映射表
     */
    public Map<Integer, Integer> getLevelStatistics() {
        return levelIndex.entrySet().stream()
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        entry -> entry.getValue().size()
                ));
    }

    /**
     * 获取最强的修炼者（按等级排序）
     *
     * @return 等级最高的修炼者，如果没有修炼者返回null
     */
    public BaseCultivator getStrongestCultivator() {
        return cultivators.values().stream()
                .max(Comparator.comparing(c -> c.getLevel().getCurrentValue()))
                .orElse(null);
    }

    /**
     * 获取最弱的修炼者（按等级排序）
     *
     * @return 等级最低的修炼者，如果没有修炼者返回null
     */
    public BaseCultivator getWeakestCultivator() {
        return cultivators.values().stream()
                .min(Comparator.comparing(c -> c.getLevel().getCurrentValue()))
                .orElse(null);
    }

    /**
     * 随机获取一个修炼者
     *
     * @return 随机修炼者，如果没有修炼者返回null
     */
    public BaseCultivator getRandomCultivator() {
        if (cultivators.isEmpty()) {
            return null;
        }
        List<BaseCultivator> cultivatorList = new ArrayList<>(cultivators.values());
        return cultivatorList.get(new Random().nextInt(cultivatorList.size()));
    }

    /**
     * 随机获取一个修炼者ID
     *
     * @return 随机修炼者ID，如果没有修炼者返回null
     */
    public String getRandomCultivatorId() {
        if (cultivators.isEmpty()) {
            return null;
        }
        List<String> idList = new ArrayList<>(cultivators.keySet());
        return idList.get(new Random().nextInt(idList.size()));
    }

    /**
     * 批量生成随机修炼者
     *
     * @param count 要生成的修炼者数量
     * @return 生成的修炼者ID列表
     */
    public List<String> generateRandomCultivators(int count) {
        List<BaseCultivator> randomCultivators = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            BaseCultivator cultivator = new BaseCultivator().randomAssignmentMethod();
            randomCultivators.add(cultivator);
        }
        return addCultivators(randomCultivators);
    }

    /**
     * 检查是否存在指定ID的修炼者
     *
     * @param id 修炼者ID
     * @return 是否存在
     */
    public boolean containsCultivator(String id) {
        return cultivators.containsKey(id);
    }

    /**
     * 检查是否存在指定名称的修炼者
     *
     * @param name 修炼者名称
     * @return 是否存在
     */
    public boolean containsCultivatorByName(String name) {
        return cultivators.values().stream()
                .anyMatch(cultivator -> cultivator.getName().equals(name));
    }

    /**
     * 更新修炼者信息（当修炼者属性变化时调用）
     *
     * @param id                修炼者ID
     * @param updatedCultivator 更新后的修炼者对象
     * @return 是否更新成功
     */
    public boolean updateCultivator(String id, BaseCultivator updatedCultivator) {
        if (!cultivators.containsKey(id)) {
            return false;
        }

        BaseCultivator oldCultivator = cultivators.get(id);

        // 如果等级发生变化，更新等级索引
        int oldLevel = oldCultivator.getLevel().getCurrentValue().intValue();
        int newLevel = updatedCultivator.getLevel().getCurrentValue().intValue();
        if (oldLevel != newLevel) {
            levelIndex.getOrDefault(oldLevel, new ArrayList<>()).remove(id);
            levelIndex.computeIfAbsent(newLevel, k -> new ArrayList<>()).add(id);
        }

        // 更新修炼者对象
        cultivators.put(id, updatedCultivator);
        return true;
    }

    /**
     * 批量更新修炼者等级索引（当批量修改等级时调用）
     */
    public void refreshLevelIndex() {
        levelIndex.clear();
        cultivators.forEach((id, cultivator) -> {
            int level = cultivator.getLevel().getCurrentValue().intValue();
            levelIndex.computeIfAbsent(level, k -> new ArrayList<>()).add(id);
        });
    }

    /**
     * 获取修炼者信息摘要
     *
     * @param id 修炼者ID
     * @return 信息摘要字符串
     */
    public String getCultivatorSummary(String id) {
        BaseCultivator cultivator = cultivators.get(id);
        if (cultivator == null) {
            return "修炼者不存在";
        }
        return String.format("%s (等级: %d, 生命值: %.1f/%.1f, 攻击力: %.1f/%.1f)",
                cultivator.getName(),
                cultivator.getLevel().getCurrentValue().intValue(),
                cultivator.getHp().getCurrentValue(),
                cultivator.getHp().getMaxValue(),
                cultivator.getAtk().getCurrentValue(),
                cultivator.getAtk().getMaxValue());
    }

    /**
     * 获取所有修炼者的简要信息
     *
     * @return 所有修炼者的简要信息列表
     */
    public List<String> getAllCultivatorSummaries() {
        return cultivators.entrySet().stream()
                .map(entry -> String.format("%s: %s", entry.getKey(), getCultivatorSummary(entry.getKey())))
                .collect(Collectors.toList());
    }

    /**
     * 对所有的AI修炼者进行时间流逝处理
     */
    @Override
    public void timePasses() {
        // cultivators.values().forEach(BaseCultivator::timePasses);
    }
}