-- Store the queue state
local spell_queue = {
  words = {},
  current_index = 1,
  is_running = false,
}

-- Function to find all misspelled words in buffer
local function find_all_misspelled_words(bufnr)
  local words = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  
  for row, line in ipairs(lines) do
    local col = 1
    while col <= #line do
      local word_start = line:find('%w', col)
      if not word_start then break end
      
      local word_end = line:find('%W', word_start) or (#line + 1)
      local word = line:sub(word_start, word_end - 1)
      
      if vim.fn.spellbadword(word)[1] ~= "" then
        table.insert(words, {
          word = word,
          row = row - 1,  -- 0-indexed
          start_col = word_start - 1,  -- 0-indexed
          end_col = word_end - 1,
        })
      end
      
      col = word_end
    end
  end
  
  return words
end

-- Function to process next word in queue
local function process_next_misspelled_word()
  if not spell_queue.is_running then
    return
  end
  
  if spell_queue.current_index > #spell_queue.words then
    print("Spell check complete! Fixed " .. (#spell_queue.words) .. " words.")
    spell_queue.is_running = false
    spell_queue.words = {}
    spell_queue.current_index = 1
    return
  end
  
  local bufnr = vim.api.nvim_get_current_buf()
  local word_info = spell_queue.words[spell_queue.current_index]
  
  -- Move cursor to the word
  vim.api.nvim_win_set_cursor(0, {word_info.row + 1, word_info.start_col})
  
  -- Re-check if word is still misspelled (in case buffer changed)
  local current_word = vim.fn.expand('<cword>')
  if vim.fn.spellbadword(current_word)[1] == "" then
    spell_queue.current_index = spell_queue.current_index + 1
    process_next_misspelled_word()
    return
  end
  
  local suggestions = vim.fn.spellsuggest(current_word)
  if #suggestions == 0 then
    print("No suggestions for '" .. current_word .. "', skipping...")
    spell_queue.current_index = spell_queue.current_index + 1
    vim.defer_fn(process_next_misspelled_word, 500)
    return
  end
  
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local themes = require('telescope.themes')
  
  -- Add options to skip or stop
  local options = vim.list_extend({'[Skip this word]', '[Stop spell check]'}, suggestions)
  
  pickers.new(themes.get_cursor(), {
    prompt_title = string.format("Word %d/%d: Replace '%s' with:", 
                                 spell_queue.current_index, 
                                 #spell_queue.words, 
                                 current_word),
    finder = finders.new_table({
      results = options
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        
        if selection then
          local choice = selection[1]
          
          if choice == '[Stop spell check]' then
            print("Spell check stopped.")
            spell_queue.is_running = false
            spell_queue.words = {}
            spell_queue.current_index = 1
            return
          elseif choice == '[Skip this word]' then
            spell_queue.current_index = spell_queue.current_index + 1
            process_next_misspelled_word()
            return
          else
            -- Replace the word
            vim.api.nvim_buf_set_text(bufnr, word_info.row, word_info.start_col, 
                                     word_info.row, word_info.end_col, { choice })
            spell_queue.current_index = spell_queue.current_index + 1
            process_next_misspelled_word()
          end
        end
      end)
      
      -- Add numbered shortcuts (1-9) - accounting for skip/stop options
      for i = 1, 9 do
        map('i', tostring(i), function()
          actions.close(prompt_bufnr)
          
          if i == 1 then
            -- Skip
            spell_queue.current_index = spell_queue.current_index + 1
            process_next_misspelled_word()
          elseif i == 2 then
            -- Stop
            print("Spell check stopped.")
            spell_queue.is_running = false
            spell_queue.words = {}
            spell_queue.current_index = 1
          elseif suggestions[i - 2] then
            -- Replace with suggestion
            vim.api.nvim_buf_set_text(bufnr, word_info.row, word_info.start_col, 
                                     word_info.row, word_info.end_col, { suggestions[i - 2] })
            spell_queue.current_index = spell_queue.current_index + 1
            process_next_misspelled_word()
          end
        end)
      end
      
      -- Map Esc to stop
      map('i', '<Esc>', function()
        actions.close(prompt_bufnr)
        print("Spell check stopped.")
        spell_queue.is_running = false
        spell_queue.words = {}
        spell_queue.current_index = 1
      end)
      
      return true
    end,
  }):find()
end

-- Command to fix all misspelled words
vim.api.nvim_create_user_command('SpellReplaceAll', function()
  if spell_queue.is_running then
    print("Spell check already running!")
    return
  end
  
  local bufnr = vim.api.nvim_get_current_buf()
  spell_queue.words = find_all_misspelled_words(bufnr)
  spell_queue.current_index = 1
  
  if #spell_queue.words == 0 then
    print("No misspelled words found!")
    return
  end
  
  print("Found " .. #spell_queue.words .. " misspelled words. Starting spell check...")
  spell_queue.is_running = true
  process_next_misspelled_word()
end, { desc = "Check and replace all misspelled words sequentially" })

-- Original single-word command
vim.api.nvim_create_user_command('SpellReplace', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local word = vim.fn.expand('<cword>')
  local row = vim.fn.line('.') - 1
  
  vim.cmd('normal! viw')
  vim.cmd('normal! \27')
  
  local start_col = vim.fn.col("'<") - 1
  local end_col = vim.fn.col("'>")
  
  if vim.fn.spellbadword(word)[1] == "" then
    print("Word is not misspelled!")
    return
  end
  
  local suggestions = vim.fn.spellsuggest(word)
  if #suggestions == 0 then
    print("No suggestions found!")
    return
  end
  
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local themes = require('telescope.themes')
  
  pickers.new(themes.get_cursor(), {
    prompt_title = "Replace '" .. word .. "' with:",
    finder = finders.new_table({
      results = suggestions
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.api.nvim_buf_set_text(bufnr, row, start_col, row, end_col, { selection[1] })
        end
      end)
      
      for i = 1, 9 do
        map('i', tostring(i), function()
          actions.close(prompt_bufnr)
          if suggestions[i] then
            vim.api.nvim_buf_set_text(bufnr, row, start_col, row, end_col, { suggestions[i] })
          end
        end)
      end
      
      return true
    end,
  }):find()
end, { desc = "Suggest and replace misspelled word" })
