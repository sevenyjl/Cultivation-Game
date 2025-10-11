package com.seven.game.cultivation.manager;

import com.seven.game.cultivation.core.TimePasses;
import com.seven.game.cultivation.entity.Place;
import lombok.Data;
import lombok.experimental.Accessors;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * 地点管理器
 * 用于管理修仙世界中的所有地点
 */
@Data
@Accessors(chain = true)
@Component
public class PlaceManager implements TimePasses {

    /**
     * 存储所有地点的映射表
     * key: 地点ID
     * value: 地点对象
     */
    private Map<String, Place> places = new ConcurrentHashMap<>();

    /**
     * 添加一个地点到管理器
     *
     * @param place 要添加的地点
     * @return 生成的地点ID
     */
    public String addPlace(Place place) {
        String id = UUID.randomUUID().toString();
        places.put(id, place);
        return id;
    }

    /**
     * 批量添加地点
     *
     * @param places 地点列表
     * @return 生成的ID列表
     */
    public List<String> addPlaces(List<Place> places) {
        return places.stream()
                .map(this::addPlace)
                .collect(Collectors.toList());
    }

    /**
     * 根据ID获取地点
     *
     * @param id 地点ID
     * @return 地点对象，如果不存在返回null
     */
    public Place getPlace(String id) {
        return places.get(id);
    }

    /**
     * 根据ID删除地点
     *
     * @param id 要删除的地点ID
     * @return 被删除的地点，如果不存在返回null
     */
    public Place removePlace(String id) {
        Place removed = places.remove(id);
        return removed;
    }

    /**
     * 获取所有地点
     *
     * @return 所有地点的列表
     */
    public List<Place> getAllPlaces() {
        return new ArrayList<>(places.values());
    }

    /**
     * 获取地点数量
     *
     * @return 当前管理的地点总数
     */
    public int getPlaceCount() {
        return places.size();
    }

    /**
     * 清空所有地点
     */
    public void clearAll() {
        places.clear();
    }

    @Override
    public void timePasses() {
        getAllPlaces().forEach(Place::action);
    }
}