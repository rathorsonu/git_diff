class CommitsController < ApplicationController
  def show
    commit_data = Octokit.commit("#{params[:owner]}/#{params[:repository]}", params[:commit_sha])
    diff_data = Octokit.compare("#{params[:owner]}/#{params[:repository]}", params[:commit_sha] + '^', params[:commit_sha])
    processed_files_diff = process_files(diff_data.files)
    processed_files_commit = process_files(commit_data.files)
    render json: { commit_data: commit_data, diff_data: { files: processed_files_diff } }
  end
  private
  def process_files(files)
    files.map do |file|
      if file[:patch]
        file[:patch] = format_patch(file[:patch])
      end
      file
    end
  end
  def format_patch(patch)
    
    result = []
    start_line_numbers = patch.scan(/@@ -\d+,\d+ \+(\d+),\d+ @@/).flatten.map(&:to_i)
    current_line_number = start_line_numbers.first || 1
    one_index = current_line_number
    second_index = current_line_number
    patch_lines = patch.lines.map(&:chomp)
    patch_lines.each do |line|     
      if line.start_with?('@@')
        result << "%3s %3s" % ['@', line[1..-1]]
      elsif line.start_with?('-')
        result << "%3d  %3s  %s" % [one_index,  '-', line[1..-1]]
        one_index += 1
      elsif line.start_with?('+')
        result << "%3s %3s %3s  %s" % ["",second_index, '+', line[1..-1]]
        second_index += 1
      else
        result << "%3d %3d %3s  %s" % [one_index, second_index, '', line]
        one_index += 1
        second_index +=1
      end
    end
    formatted_result = [result]
    formatted_result
  end
end
