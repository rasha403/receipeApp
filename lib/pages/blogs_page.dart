// lib/pages/blogs_page.dart
import 'package:flutter/material.dart';
import 'package:recipe_book/AppBar/app_bar.dart';
import 'package:recipe_book/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlogsPage extends StatefulWidget {
  const BlogsPage({super.key});

  @override
  State<BlogsPage> createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _blogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final blogs = await _dbHelper.getAllBlogs();
      setState(() {
        _blogs = blogs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading blogs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Blogs',
        onLanguageChanged: (languageCode) {
          print('Language changed to: $languageCode');
        },
        onFavoriteToggle: (userId, recipeId, isFavorite) {
          print('Favorite updated: $recipeId = $isFavorite');
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Published Blogs',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_blogs.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No blogs yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Be the first to share your culinary insights!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadBlogs,
                  child: ListView.builder(
                    itemCount: _blogs.length,
                    itemBuilder: (context, index) {
                      final blog = _blogs[index];
                      return BlogCard(
                        blog: blog,
                        onRefresh: _loadBlogs,
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBlogPage(),
            ),
          );
          if (shouldRefresh == true) {
            _loadBlogs();
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Blog',
      ),
    );
  }
}

class BlogCard extends StatelessWidget {
  final Map<String, dynamic> blog;
  final VoidCallback onRefresh;

  const BlogCard({
    Key? key,
    required this.blog,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePath = blog['imagePath'] ?? 'assets/images/blogs.png';
    final author = blog['author'];
    final title = blog['title'];
    final createdAt = DateTime.parse(blog['createdAt']);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailPage(
                blog: blog,
                onRefresh: onRefresh,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                imagePath,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'By $author',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Published: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({super.key});

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add New Blog',
        onLanguageChanged: (languageCode) {
          print('Language changed to: $languageCode');
        },
        onFavoriteToggle: (userId, recipeId, isFavorite) {
          print('Favorite updated: $recipeId = $isFavorite');
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Blog Title *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
              
            ),
            SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: 'Author Name *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Blog Content *',
                  hintText: 'Start writing your blog post here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Simulate image picker
                      setState(() {
                        _selectedImagePath = 'assets/images/blogs.jpg'; // Default image
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Default image selected')),
                      );
                    },
                    icon: Icon(Icons.image),
                    label: Text('Add Cover Image'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                if (_selectedImagePath != null)
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Image Selected',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBlog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Publish Blog'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitBlog() async {
    if (_titleController.text.isEmpty ||
        _authorController.text.isEmpty ||
        _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (_contentController.text.split('\n').length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Content must not exceed 100 lines')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final blogData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'author': _authorController.text,
        'imagePath': _selectedImagePath,
      };

      await DatabaseHelper.instance.insertBlog(blogData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blog published successfully!')),
      );

      // Pop the page and return true to indicate success
      Navigator.pop(context, true);
    } catch (e) {
      print('Error submitting blog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error publishing blog: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class BlogDetailPage extends StatelessWidget {
  final Map<String, dynamic> blog;
  final VoidCallback onRefresh;

  const BlogDetailPage({
    Key? key,
    required this.blog,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePath = blog['imagePath'] ?? 'assets/images/blogs.png';
    final author = blog['author'];
    final title = blog['title'];
    final content = blog['content'];
    final createdAt = DateTime.parse(blog['createdAt']);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Blog Details',
        onLanguageChanged: (languageCode) {
          print('Language changed to: $languageCode');
        },
        onFavoriteToggle: (userId, recipeId, isFavorite) {
          print('Favorite updated: $recipeId = $isFavorite');
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'By $author',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Published: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}