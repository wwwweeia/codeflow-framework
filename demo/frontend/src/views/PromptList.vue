<template>
  <div class="prompt-list">
    <!-- 搜索区 -->
    <div class="search-area">
      <el-form :inline="true" :model="searchForm" @submit.prevent="handleSearch">
        <el-form-item label="标题关键词">
          <el-input
            v-model="searchForm.keyword"
            placeholder="请输入标题关键词"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="标签筛选">
          <el-select
            v-model="searchForm.tags"
            multiple
            clearable
            placeholder="请选择标签"
            collapse-tags
            collapse-tags-tooltip
            style="width: 240px"
          >
            <el-option
              v-for="tag in promptStore.allTags"
              :key="tag"
              :label="tag"
              :value="tag"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 表格区 -->
    <el-table
      v-loading="promptStore.loading"
      :data="promptStore.filteredPrompts"
      style="width: 100%"
      empty-text="暂无数据"
      :default-sort="{ prop: 'createdTime', order: 'descending' }"
    >
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="title" label="标题" min-width="160" show-overflow-tooltip />
      <el-table-column label="内容摘要" min-width="240">
        <template #default="{ row }">
          <span class="content-cell" :title="row.content">{{ truncate(row.content, 50) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="标签" width="200">
        <template #default="{ row }">
          <div class="tag-group">
            <el-tag
              v-for="tag in row.tags"
              :key="tag"
              size="small"
              class="tag-item"
            >
              {{ tag }}
            </el-tag>
          </div>
        </template>
      </el-table-column>
      <el-table-column
        prop="createdTime"
        label="创建时间"
        width="180"
        sortable
      />
    </el-table>

    <!-- 底部信息 -->
    <div class="table-footer">
      <span class="total-count">共 {{ promptStore.filteredPrompts.length }} 条记录</span>
    </div>
  </div>
</template>

<script setup>
import { reactive, onMounted } from 'vue'
import { usePromptStore } from '../stores/prompt'

const promptStore = usePromptStore()

// 搜索表单（与 Store searchForm 保持同步）
const searchForm = reactive({
  keyword: '',
  tags: [],
})

/** 截断文本 */
function truncate(text, maxLen) {
  if (!text) return ''
  return text.length > maxLen ? text.slice(0, maxLen) + '...' : text
}

/** 搜索：将组件搜索条件同步到 Store */
function handleSearch() {
  promptStore.search(searchForm.keyword, searchForm.tags)
}

/** 重置：清空组件搜索条件，同步重置 Store */
function handleReset() {
  searchForm.keyword = ''
  searchForm.tags = []
  promptStore.resetSearch()
}

onMounted(() => {
  promptStore.fetchPrompts()
})
</script>

<style scoped>
.prompt-list {
  padding: 20px;
  background: #fff;
  min-height: calc(100vh - 60px);
}

.search-area {
  margin-bottom: 20px;
  padding: 16px 20px;
  border-radius: 4px;
}

.content-cell {
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.tag-group {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.tag-item {
  margin-right: 0;
}

.table-footer {
  margin-top: 16px;
  text-align: right;
}

.total-count {
  font-size: 13px;
  color: #909399;
}
</style>
