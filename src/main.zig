const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    try stdout.print("= What name should the file have? (using an existing name will overwrite that file!):\n", .{});

    var filename_buf: [128]u8 = undefined;
    const filename = try stdin.readUntilDelimiterOrEof(&filename_buf, '\n');
    const filename_trimmed = std.mem.trimRight(u8, filename.?, "\r\n");
    const file = try std.fs.cwd().createFile(filename_trimmed, .{ .read = true });
    defer file.close();

    const finishing_string = "Done";

    var tasks: [128][]const u8 = undefined;
    var index: usize = 0;
    var buffers: [128][128]u8 = undefined; // 128 tasks with 128 characters availible for each.

    try stdout.print("= Write tasks to do, write 'Done' when you are finished:\n", .{});

    while (true) {
        if (index == buffers.len - 1) {
            try stdout.print("= Task limit reached!", .{});
        }

        const task = try stdin.readUntilDelimiterOrEof(&buffers[index], '\n');
        const task_trimmed = std.mem.trimRight(u8, task.?, "\r\n");

        if (std.mem.eql(u8, task_trimmed, finishing_string)) {
            break;
        }

        tasks[index] = task_trimmed;
        index += 1;
    }

    for (tasks, 0..) |task, i| {
        if (i == index) break;
        const alloc = std.heap.page_allocator;

        try file.writeAll(try std.fmt.allocPrint(alloc, "{}", .{i + 1}));
        try file.writeAll(") ");
        try file.writeAll(task);
        try file.writeAll(" [x]\n");
    }

    try stdout.print("= Tasks have been written to '{s}', exiting.", .{filename_trimmed});
}
